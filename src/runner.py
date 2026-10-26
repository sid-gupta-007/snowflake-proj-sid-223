"""
Migration & Deployment Runner for Snowflake Retail Analytics Platform.
Executes SQL scripts in order against Snowflake with comprehensive logging and error handling.
"""

import sys
import argparse
from pathlib import Path
from typing import List

ROOT_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT_DIR))

from src.config import SnowflakeConfig
from src.snowflake_client import SnowflakeClient, logger
SQL_DIR = ROOT_DIR / "sql"

STAGES = [
    ("00_setup", "Environment, Warehouse, Database & Schemas"),
    ("01_raw", "File Formats, Stages, Raw Tables, COPY INTO & Validation"),
    ("02_staging", "Cleaned & Standardized Staging Views"),
    ("03_curated", "Dimensional Model (Dimensions & Facts)"),
    ("04_mart", "Business-Ready Reporting Marts"),
    ("05_control", "Operational Audit Logging, Streams & Tasks"),
]


def test_connection():
    """Runs a non-destructive connection test."""
    print("=" * 70)
    print("Testing Snowflake Connection...")
    print(SnowflakeConfig.summary())
    print("=" * 70)

    client = SnowflakeClient()
    result = client.test_connection()

    if result["success"]:
        print("\nConnection Successful!")
        print("-" * 50)
        for k, v in result["details"].items():
            print(f"  {k:20}: {v}")
        print("-" * 50)
        return True
    else:
        print("\nConnection Failed!")
        print(f"Error: {result['error']}")
        return False


def run_stage(stage_folder_name: str, client: SnowflakeClient):
    """Executes all .sql files inside the specified stage directory in alphabetical order."""
    stage_path = SQL_DIR / stage_folder_name
    if not stage_path.exists():
        logger.warning(f"Stage directory {stage_path} does not exist. Skipping.")
        return

    sql_files: List[Path] = sorted(list(stage_path.glob("*.sql")))
    if not sql_files:
        logger.warning(f"No .sql files found in {stage_path}.")
        return

    print(f"\n>>> Running Stage: [{stage_folder_name}] ({len(sql_files)} scripts)")
    for sql_file in sql_files:
        print(f"  Executing {sql_file.name}...", end=" ", flush=True)
        try:
            sql_content = sql_file.read_text(encoding="utf-8")
            client.execute_script(sql_content)
            print("[DONE]")
        except Exception as e:
            print("[FAILED]")
            logger.error(f"Error running {sql_file.name}: {str(e)}")
            raise


def main():
    parser = argparse.ArgumentParser(description="Snowflake Retail Analytics Deployment CLI")
    parser.add_argument(
        "--test",
        action="store_true",
        help="Test Snowflake connection and exit without running migrations",
    )
    parser.add_argument(
        "--stage",
        type=str,
        choices=[s[0] for s in STAGES] + ["all"],
        default="all",
        help="Specific stage to deploy, or 'all'",
    )
    args = parser.parse_args()

    validation = SnowflakeConfig.validate()
    if not validation["valid"]:
        print("\nConfiguration Errors Detected:")
        for err in validation["errors"]:
            print(f"  - {err}")
        print("\nPlease update your .env file before running deployments.")
        sys.exit(1)

    if args.test:
        success = test_connection()
        sys.exit(0 if success else 1)

    # Perform connection test before running migrations
    if not test_connection():
        print("Cannot proceed with deployment: Snowflake connection test failed.")
        sys.exit(1)

    client = SnowflakeClient()
    if args.stage == "all":
        for stage_name, description in STAGES:
            print(f"\n=======================================================")
            print(f"Stage: {stage_name} - {description}")
            print(f"=======================================================")
            run_stage(stage_name, client)
    else:
        run_stage(args.stage, client)

    print("\nDeployment completed successfully!")


if __name__ == "__main__":
    main()
