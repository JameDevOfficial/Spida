import os
import shutil
import subprocess
import platform
import time
import zipfile
from pathlib import Path
import urllib.request

def run(cmd, cwd=None):
    current_dir = os.getcwd()
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd)
    if result.returncode != 0:
        print(f"Command failed: {cmd}")
    return result.returncode == 0

def remove_readonly(func, path, excinfo):
    """Error handler for Windows readonly files."""
    os.chmod(path, 0o777)
    func(path)

def safe_rmtree(path, retries=3, delay=1):
    """Safely remove directory tree with retries."""
    for attempt in range(retries):
        try:
            if path.exists():
                shutil.rmtree(path, onerror=remove_readonly)
            return True
        except PermissionError as e:
            if attempt < retries - 1:
                print(f"Retry {attempt + 1}/{retries} - waiting {delay}s...")
                time.sleep(delay)
            else:
                print(f"Error: Could not delete {path}")
                print(f"Please close any programs using files in this directory")
                print(f"Or manually delete: {path}")
                return False
    return False

def download_love(version, arch, dest_dir):
    """Download LÖVE framework for Windows."""
    url = f"https://github.com/love2d/love/releases/download/{version}/love-{version}-win{arch}.zip"
    zip_path = dest_dir / f"love-win{arch}.zip"
    
    print(f"Downloading LÖVE {version} ({arch}-bit)...")
    try:
        urllib.request.urlretrieve(url, zip_path)
        return zip_path
    except Exception as e:
        print(f"Failed to download: {e}")
        return None

def create_windows_exe(love_file, love_version, arch, output_dir):
    """Create Windows executable by merging .love with LÖVE."""
    temp_dir = output_dir / f"temp_win{arch}"
    temp_dir.mkdir(exist_ok=True)
    
    # Download and extract LÖVE
    love_zip = download_love(love_version, arch, temp_dir)
    if not love_zip:
        return False
    
    print(f"Extracting LÖVE {arch}-bit...")
    with zipfile.ZipFile(love_zip, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)
    
    # Find the extracted LÖVE folder
    love_dir = next(temp_dir.glob(f"love-{love_version}-win{arch}"))
    
    # Merge .love file with love.exe
    exe_path = love_dir / "love.exe"
    game_exe = love_dir / "Spida.exe"
    
    print(f"Creating Spida.exe ({arch}-bit)...")
    with open(game_exe, 'wb') as outfile:
        with open(exe_path, 'rb') as exe:
            outfile.write(exe.read())
        with open(love_file, 'rb') as love:
            outfile.write(love.read())
    
    # Remove original love.exe
    exe_path.unlink()
    
    # Create zip archive
    output_zip = output_dir / f"Spida-win{arch}.zip"
    print(f"Creating zip archive: {output_zip.name}")
    shutil.make_archive(str(output_zip.with_suffix('')), 'zip', love_dir)
    
    # Clean up temp directory
    safe_rmtree(temp_dir)
    
    return True

def main():
    root = Path.cwd()
    releases = root / "releases"
    game_src = root / "src"
    game_dst = releases / "game"
    executables = releases / "executables"
    web = releases / "web"
    love_file = releases / "Spida.love"
    
    # LÖVE version to use
    LOVE_VERSION = "11.5"

    # Step 0: Clean up old releases
    if releases.exists():
        print("Deleting old releases directory...")
        if not safe_rmtree(releases):
            user_input = input("Continue anyway? (y/n): ")
            if user_input.lower() != 'y':
                return

    # Step 1: Create directory structure
    print("Creating releases directory structure...")
    executables.mkdir(parents=True, exist_ok=True)
    game_dst.mkdir(parents=True, exist_ok=True)
    web.mkdir(parents=True, exist_ok=True)

    # Step 2: Copy game files
    print("Copying game files...")
    shutil.copytree(game_src, game_dst, dirs_exist_ok=True)

    # Step 3: Create .love file
    print("Creating .love file...")
    if love_file.exists():
        love_file.unlink()
    shutil.make_archive(str(love_file.with_suffix('')), 'zip', root_dir=game_dst)
    zip_path = love_file.with_suffix('.zip')
    if zip_path.exists():
        zip_path.rename(love_file)

    # Step 4: Build Windows executables
    print("\nBuilding Windows executables...")
    create_windows_exe(love_file, LOVE_VERSION, "32", executables)
    create_windows_exe(love_file, LOVE_VERSION, "64", executables)

    # Step 5: Build web version with love.js
    os.chdir(root)
    print("\nBuilding web version...")
    is_wsl = "Microsoft" in platform.uname().release
    
    # Convert WSL paths to Windows paths for love.js if needed
    if is_wsl:
        # Convert /mnt/c/... to C:\...
        love_file_win = str(love_file).replace('/mnt/c/', 'C:\\').replace('/', '\\')
        web_win = str(web).replace('/mnt/c/', 'C:\\').replace('/', '\\')
        lovejs_cmd = f"npx love.js.cmd -c \"{love_file_win}\" \"{web_win}\" --title \"Falling Bird\""
    else:
        lovejs_cmd = f"npx love.js.cmd -c \"{love_file}\" \"{web}\" --title \"Falling Bird\""
    
    run(lovejs_cmd)

    # Step 6: Build summary
    print("\nBuild Summary:\n===============")
    checks = {
        ".love file": love_file,
        "Windows 32-bit": executables / "Spida-win32.zip",
        "Windows 64-bit": executables / "Spida-win64.zip", 
        "Web version": web / "index.html"
    }
    for name, path in checks.items():
        status = '✓' if path.exists() else '✗'
        print(f"{status} {name}: {path if path.exists() else 'build missing!'}")

    print("\nAll builds completed! Check ./releases/ directory.")

if __name__ == "__main__":
    main()