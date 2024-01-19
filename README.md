# Xmonad windowmanager, fonts and basic tools
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
sudo apt install fonts-jetbrains-mono fonts-ubuntu fonts-font-awesome fonts-mononoki fonts-noto fonts-hack-ttf

sudo apt update
sudo apt upgrade
sudo apt install xmobar dmenu feh trayer
```

# Composition (transparency)
```bash
sudo apt install compton
```

# Terminalemulator
```bash
sudo add-apt-repository ppa:aslatter/ppa -y
sudo apt install alacritty
```

# Terminal multiplexer
```bash
sudo apt install tmux
```

# ZSH + oh-my-zsh
```bash
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

