# Xmonad windowmanager and basic tool
We have to install xmonad manually because the ubuntu repos are outdated as usual.
(See https://xmonad.org/INSTALL.html)
Current xmonad version 0.17 is already 3 years old or older. No update in the repositories.
```bash
mkdir -p ~/config/.xmonad && cd ~/config/.xmonad
sudo apt install libx11-dev libxft-dev libxinerama-dev libxrandr-dev libxss-dev curl git
git clone --branch v0.17.2 https://github.com/xmonad/xmonad
git clone --branch master https://github.com/xmonad/xmonad-contrib
curl -sSL https://get.haskellstack.org/ | sh
mkdir -p ~/.local/bin
export PATH=~/.local/bin:$PATH
stack init
stack install

sudo apt update
sudo apt upgrade
sudo apt install xmobar dmenu feh trayer
```

# Compton composite manager for transparencies
```bash
sudo apt install compton 
```

# Terminalemulator
```bash
```

