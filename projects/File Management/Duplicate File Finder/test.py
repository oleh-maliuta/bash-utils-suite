import pytest
import os
import shutil
import subprocess
from pathlib import Path

# --- Configuration ---
RUN_SCRIPT = "./run.sh"
TEST_DIR = "./.test_env"
TARGET_DIR = os.path.join(TEST_DIR, "target")
TRASH_DIR = os.path.join(TEST_DIR, "trash")
LOG_FILE = os.path.join(TEST_DIR, "log.txt")

# --- Fixtures (Setup & Teardown) ---

@pytest.fixture
def setup_test_env():
    """
    Creates the test directory structure and dummy files with specific 
    content and timestamps to simulate duplicates.
    """
    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)
    
    os.makedirs(TARGET_DIR)

    # file_A.txt: Original (Oldest)
    path_a = os.path.join(TARGET_DIR, "file_A.txt")
    with open(path_a, "w") as f:
        f.write("duplicate_content")
    os.utime(path_a, (1000, 1000))

    # file_B.txt: Duplicate (Newer)
    path_b = os.path.join(TARGET_DIR, "file_B.txt")
    with open(path_b, "w") as f:
        f.write("duplicate_content")
    os.utime(path_b, (2000, 2000))

    # file_C.txt: Unique File
    path_c = os.path.join(TARGET_DIR, "file_C.txt")
    with open(path_c, "w") as f:
        f.write("unique_content")
    os.utime(path_c, (1500, 1500))

    yield

    if os.path.exists(TEST_DIR):
        shutil.rmtree(TEST_DIR)

# --- Helper Functions ---

def run_script(args):
    """Executes the ./run.sh script with provided arguments."""
    cmd = [RUN_SCRIPT] + args
    subprocess.run(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

def assert_exists(file_path):
    """Asserts that a file exists."""
    assert os.path.exists(file_path), f"There is no such file ({file_path})."

def assert_missing(file_path):
    """Asserts that a file does NOT exist."""
    assert not os.path.exists(file_path), f"This file shouldn't exist ({file_path})."

# --- Test Cases ---

def test_default_behavior(setup_test_env):
    """Test that duplicates are moved to the trash directory by default."""
    run_script([TARGET_DIR, "-t", TRASH_DIR, "-l", LOG_FILE])

    assert_exists(os.path.join(TARGET_DIR, "file_A.txt"))
    assert_exists(os.path.join(TARGET_DIR, "file_C.txt"))

    assert_missing(os.path.join(TARGET_DIR, "file_B.txt"))
    assert_exists(os.path.join(TRASH_DIR, "file_B.txt"))


def test_remove_flag(setup_test_env):
    """Test the -r flag to permanently delete duplicates."""
    run_script([TARGET_DIR, "-t", TRASH_DIR, "-r", "-l", LOG_FILE])

    assert_exists(os.path.join(TARGET_DIR, "file_A.txt"))
    assert_exists(os.path.join(TARGET_DIR, "file_C.txt"))

    assert_missing(os.path.join(TARGET_DIR, "file_B.txt"))
    assert_missing(os.path.join(TRASH_DIR, "file_B.txt"))


def test_dry_run(setup_test_env):
    """Test the -n (dry run) flag. No files should change locations."""
    run_script([TARGET_DIR, "-n", "-t", TRASH_DIR, "-l", LOG_FILE])

    assert_exists(os.path.join(TARGET_DIR, "file_A.txt"))
    assert_exists(os.path.join(TARGET_DIR, "file_B.txt"))
    assert_exists(os.path.join(TARGET_DIR, "file_C.txt"))
    
    assert_missing(os.path.join(TRASH_DIR, "file_B.txt"))