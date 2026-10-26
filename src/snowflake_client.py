"""
Snowflake Secure Client Module.
Supports Password and Key-Pair Authentication, parameterized query execution,
and transaction/script handling with full error masking.
"""

import logging
from typing import Optional, Dict, Any, List, Tuple

try:
    import snowflake.connector
    from snowflake.connector import SnowflakeConnection
    from snowflake.connector.cursor import SnowflakeCursor
    SNOWFLAKE_AVAILABLE = True
except ImportError:
    SNOWFLAKE_AVAILABLE = False
    SnowflakeConnection = Any  # type: ignore
    SnowflakeCursor = Any  # type: ignore

try:
    import pandas as pd
except ImportError:
    pd = None  # type: ignore

from src.config import SnowflakeConfig

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("snowflake_client")


def _load_private_key(key_path: str, passphrase: Optional[str] = None):
    """Loads RSA private key for key-pair authentication."""
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization

    with open(key_path, "rb") as key_file:
        p_key = serialization.load_pem_private_key(
            key_file.read(),
            password=passphrase.encode() if passphrase else None,
            backend=default_backend(),
        )

    pkb = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    return pkb


class SnowflakeClient:
    """Manages connection and query execution to Snowflake."""

    def __init__(self, override_schema: Optional[str] = None):
        self.validation = SnowflakeConfig.validate()
        self.schema = override_schema or SnowflakeConfig.SCHEMA

    def get_connection(self) -> SnowflakeConnection:
        """Establishes and returns a SnowflakeConnection."""
        if not SNOWFLAKE_AVAILABLE:
            raise ImportError(
                "snowflake-connector-python is not installed. "
                "Please install dependencies with: pip install -r requirements.txt"
            )
        if not self.validation["valid"]:
            raise ValueError(f"Invalid Snowflake Configuration: {', '.join(self.validation['errors'])}")

        params: Dict[str, Any] = {
            "account": SnowflakeConfig.ACCOUNT,
            "user": SnowflakeConfig.USER,
            "role": SnowflakeConfig.ROLE,
            "warehouse": SnowflakeConfig.WAREHOUSE,
            "database": SnowflakeConfig.DATABASE,
            "schema": self.schema,
            "client_session_keep_alive": True,
        }

        if SnowflakeConfig.AUTH_TYPE == "KEYPAIR":
            logger.info("Using Key-Pair authentication.")
            pkb = _load_private_key(
                SnowflakeConfig.PRIVATE_KEY_PATH,
                SnowflakeConfig.PRIVATE_KEY_PASSPHRASE,
            )
            params["private_key"] = pkb
        else:
            logger.info("Using Password authentication.")
            params["password"] = SnowflakeConfig.PASSWORD

        return snowflake.connector.connect(**params)

    def test_connection(self) -> Dict[str, Any]:
        """
        Tests the connection and returns environment metadata.
        Does not reveal credentials.
        """
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT 
                            CURRENT_USER() AS user_name,
                            CURRENT_ROLE() AS role_name,
                            CURRENT_WAREHOUSE() AS warehouse_name,
                            CURRENT_DATABASE() AS database_name,
                            CURRENT_SCHEMA() AS schema_name,
                            CURRENT_VERSION() AS snowflake_version
                        """
                    )
                    row = cur.fetchone()
                    cols = [desc[0].lower() for desc in cur.description]
                    result = dict(zip(cols, row))
                    logger.info("Snowflake connection successful: %s", result)
                    return {"success": True, "details": result}
        except Exception as e:
            logger.error("Snowflake connection test failed: %s", str(e))
            return {"success": False, "error": str(e)}

    def execute_query(
        self, query: str, params: Optional[Tuple] = None
    ) -> List[Tuple]:
        """Executes a single SQL statement safely."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query, params)
                return cur.fetchall()

    def query_to_dataframe(
        self, query: str, params: Optional[Tuple] = None
    ) -> pd.DataFrame:
        """Executes query and returns a pandas DataFrame."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query, params)
                return cur.fetch_pandas_all()

    def execute_script(self, sql_script: str) -> List[str]:
        """
        Executes multiple semicolon-delimited SQL statements sequentially.
        Ignores empty statements.
        """
        results = []
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                statements = [s.strip() for s in sql_script.split(";") if s.strip()]
                for idx, stmt in enumerate(statements, 1):
                    # Filter out purely comment blocks
                    non_comment_lines = [
                        line for line in stmt.splitlines()
                        if not line.strip().startswith("--")
                    ]
                    if not "".join(non_comment_lines).strip():
                        continue

                    try:
                        cur.execute(stmt)
                        status = cur.status or "SUCCESS"
                        results.append(f"Statement {idx}: {status}")
                    except Exception as e:
                        logger.error("Error executing statement %d: %s\nSQL: %s", idx, str(e), stmt[:200])
                        raise
        return results
