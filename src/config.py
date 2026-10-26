"""
Configuration Manager for Snowflake Retail Analytics Platform.
Loads environment variables safely and validates required settings.
"""

import os
from pathlib import Path
from typing import Dict, Any, Optional
from dotenv import load_dotenv

# Find root directory (where .env lives)
ROOT_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = ROOT_DIR / ".env"

if ENV_PATH.exists():
    load_dotenv(dotenv_path=ENV_PATH)
else:
    load_dotenv()  # Fallback to system environment


class SnowflakeConfig:
    """Encapsulates Snowflake connection parameters with safe masking."""

    ACCOUNT: str = os.getenv("SNOWFLAKE_ACCOUNT", "")
    USER: str = os.getenv("SNOWFLAKE_USER", "")
    ROLE: str = os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN")
    WAREHOUSE: str = os.getenv("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH")
    DATABASE: str = os.getenv("SNOWFLAKE_DATABASE", "RETAIL_DB")
    SCHEMA: str = os.getenv("SNOWFLAKE_SCHEMA", "RAW")

    AUTH_TYPE: str = os.getenv("SNOWFLAKE_AUTH_TYPE", "PASSWORD").upper()
    PASSWORD: Optional[str] = os.getenv("SNOWFLAKE_PASSWORD")
    PRIVATE_KEY_PATH: Optional[str] = os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH")
    PRIVATE_KEY_PASSPHRASE: Optional[str] = os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE")

    QUERY_TIMEOUT: int = int(os.getenv("SNOWFLAKE_QUERY_TIMEOUT", "300"))

    @classmethod
    def validate(cls) -> Dict[str, Any]:
        """
        Validates configuration without exposing passwords or keys.
        Returns a dict of validation status and safe metadata.
        """
        errors = []
        if not cls.ACCOUNT:
            errors.append("SNOWFLAKE_ACCOUNT is missing.")
        if not cls.USER:
            errors.append("SNOWFLAKE_USER is missing.")

        if cls.AUTH_TYPE == "KEYPAIR":
            if not cls.PRIVATE_KEY_PATH:
                errors.append("SNOWFLAKE_AUTH_TYPE is KEYPAIR but SNOWFLAKE_PRIVATE_KEY_PATH is empty.")
            elif not Path(cls.PRIVATE_KEY_PATH).exists():
                errors.append(f"Private key file not found at: {cls.PRIVATE_KEY_PATH}")
        elif cls.AUTH_TYPE == "PASSWORD":
            if not cls.PASSWORD:
                errors.append("SNOWFLAKE_AUTH_TYPE is PASSWORD but SNOWFLAKE_PASSWORD is empty.")
        else:
            errors.append(f"Unknown SNOWFLAKE_AUTH_TYPE '{cls.AUTH_TYPE}'. Must be PASSWORD or KEYPAIR.")

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "account": cls.ACCOUNT,
            "user": cls.USER,
            "role": cls.ROLE,
            "warehouse": cls.WAREHOUSE,
            "database": cls.DATABASE,
            "schema": cls.SCHEMA,
            "auth_type": cls.AUTH_TYPE,
        }

    @classmethod
    def summary(cls) -> str:
        """Returns safe summary of configured connection target."""
        info = cls.validate()
        return (
            f"Account: {info['account'] or '<NOT SET>'} | "
            f"User: {info['user'] or '<NOT SET>'} | "
            f"Role: {info['role']} | "
            f"Warehouse: {info['warehouse']} | "
            f"DB: {info['database']} | "
            f"Auth: {info['auth_type']}"
        )
