"""
Local syntax and configuration unit tests.
Runs without requiring an active Snowflake connection.
"""

from pathlib import Path
import pytest
from src.config import SnowflakeConfig

ROOT_DIR = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT_DIR / "sql"


def test_sql_files_exist_and_readable():
    """Verify that all expected SQL stages and scripts exist and are non-empty."""
    expected_stages = [
        "00_setup",
        "01_raw",
        "02_staging",
        "03_curated",
        "04_mart",
        "05_control",
    ]
    for stage in expected_stages:
        stage_dir = SQL_DIR / stage
        assert stage_dir.exists(), f"Stage directory {stage} is missing"
        sql_files = list(stage_dir.glob("*.sql"))
        assert len(sql_files) > 0, f"No SQL files found in stage {stage}"
        for f in sql_files:
            content = f.read_text(encoding="utf-8").strip()
            assert len(content) > 0, f"SQL file {f.name} is empty"


def test_config_validation_structure():
    """Verify that SnowflakeConfig.validate returns standard keys."""
    val = SnowflakeConfig.validate()
    assert "valid" in val
    assert "errors" in val
    assert "account" in val
    assert "user" in val
    assert "auth_type" in val
