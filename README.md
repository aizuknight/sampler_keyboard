# sampler_keyboard
**sampler_keyboard** is a keyboard with 6 keys to learn the basics of custom built keyboard design.

# Bill of Materials
| Part | Quantity | Purchase |
| ---- | -------- | -------- |
| Seeed Studio XIAO RP2040 | 1 | https://akizukidenshi.com/catalog/g/g117044/, https://www.marutsu.co.jp/pc/i/2229736/ |
| Cherry compatible switch | 6 | https://shop.yushakobo.jp/collections/cherry-mx-clone |
| Switch socket | 6 | https://www.marutsu.co.jp/pc/i/40769481/, https://shop.yushakobo.jp/products/a01ps |
| PCB | 1 | Order at [JLCPCB](https://cart.jlcpcb.com/quote) |
| SK6812MINI-E | 6 | https://akizukidenshi.com/catalog/g/g115478/, https://shop.yushakobo.jp/products/sk6812mini-e-10 |
| 1N4148W | 6 | https://akizukidenshi.com/catalog/g/g107084/, https://www.marutsu.co.jp/pc/i/41883574/, https://shop.yushakobo.jp/products/a0800di-02-100 |
| M2 spacer (4mm) | 8 | https://shop.yushakobo.jp/products/a0800r2?variant=37665433944225, https://shop.yushakobo.jp/products/a0800c2?variant=37665435123873 |
| M2 screw (5mm) | 4 | https://shop.yushakobo.jp/products/a0800b2?variant=37665433321633 |
| M2 screw (8mm) | 4 | https://shop.yushakobo.jp/products/8006?variant=47615864963303, https://shop.yushakobo.jp/products/a0800n2?variant=37665433026721 |
| Switch plate (1mm thick) | 1 | Buy an acrylic panel at [hazaiya](https://www.hazaiya.co.jp/) and cut by yourself |
| Base plate (3mm thick) | 1 | Buy an acrylic panel at [hazaiya](https://www.hazaiya.co.jp/) and cut by yourself |

# How to Build Firmware
> [!NOTE]
> **If you are going to build the firmware on CentOS in AINS (University of Aizu), go straight to step 2.**

> [!TIP]
> **I recommend you to build the firmware on CentOS in the AINS (University of Aizu) if you are a beginner. You can SSH into CentOS server just by `ssh s13XXXXX@linsv.u-aizu.ac.jp` while connected to the AINS network.**
## 1. Prepare Docker Engine
If Docker is already installed and it can be run without `sudo`, go straight to step 2. The build script uses Docker. If Docker is not installed yet, install Docker Engine on your Linux system (including WSL):
```bash
curl -fsSL https://get.docker.com | sudo sh
```
If `docker` cannot be run without `sudo`, add your user to `docker` group:
```bash
sudo usermod -aG docker $USER
```
> [!NOTE]
> For the user group changes to take effect, you will need to log out. You might need to reboot your computer instead of logging out for the user group changes to take effect.

These commands require `curl` and permission to install system software.
## 2. Clone Repository
```
git clone https://github.com/aizuknight/sampler_keyboard.git
cd sampler_keyboard/
```
This command requires `git` to be installed.
## 3. Build Firmware
After cloning the repository, run the command below from the repository root (You should be there already) for your chosen keymap. The script prepares the build environment and compiles the firmware.
> [!WARNING]
> You need at least 6.16 GB of disk space with Docker.

> [!NOTE]
> The first build requires internet access and takes longer because the script automatically builds the QMK container image (about 4 minutes with Docker on Intel Core i5-12400). Later builds reuse the image.
### Option 1: Build the Default Keymap
```bash
./firmware/build.sh
```
The built firmware is located at `firmware/output/sampler_keyboard_default.uf2`.
### Option 2: Build Firmware with VIA Compatibility
```bash
./firmware/build.sh via
```
The built firmware is located at `firmware/output/sampler_keyboard_via.uf2`.

# How to Install Firmware to The Keyboard
1. Connect Seeed Studio XIAO RP2040 to your computer with USB cable **while pressing reset button on the Seeed Studio XIAO RP2040**.
2. Release the reset button on the Seeed Studio XIAO RP2040.
3. Drag and drop the firmware to the USB mass strage device named "RPI-RP2".
