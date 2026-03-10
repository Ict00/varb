# VARB
[**V**](https://github.com/vlang/v) [**A**rch](https://archlinux.org/) **R**epository **B**rowser - simple
TUI app for browsing and installing packages using pacman

## Usage

| Key                       | Action                                                                                              |
|---------------------------|-----------------------------------------------------------------------------------------------------|
| **W**/**S**               | Move cursor up/down                                                                                 |
| **D**/**Enter**/**Space** | When in package list - opens selected package window; when in package window - installs the package |
| **F**                     | Search for package. Press **Enter** to refresh package list then                                    |

...That's all.

The project is mostly experimental, but there are some features planned to be added, like **AUR**.

**Supported platforms**
* [x] Arch Linux (obviously)

1. You need to get [**V** compiler](https://github.com/vlang/v).
2. Clone the repository and go to the project directory:
```bash
$ git clone https://github.com/Ict00/varb.git
$ cd varb
```
3. Build the project using the V compiler:
```bash
$ v .
```
4. Done! Now you have **varb** executable in the directory.

