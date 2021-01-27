# MailTrackerBlocker [![Awesome Humane Tech](https://raw.githubusercontent.com/humanetech-community/awesome-humane-tech/main/humane-tech-badge.svg?sanitize=true)](https://github.com/humanetech-community/awesome-humane-tech)

MailTrackerBlocker is a plugin (mailbundle) for the default Mail app built-in to macOS. Email marketers and other interests often embed these trackers in HTML emails so they can track how often, when and where you open your emails. This plugin works by stripping out a good majority of these spy pixels out of the HTML before display, rendering the typical advice of disabling "load remote content in messages" unnecessary.

MailTrackerBlocker makes it possible to browse your inbox privately with images displayed once again.

[Read more about how email pixel tracking works.](https://www.gmass.co/blog/tracking-pixel-blockers/)

<p align="center"><img width="371" src="https://user-images.githubusercontent.com/47551890/89727857-6d625600-da63-11ea-91b9-90f48301dc05.png"></p>

```diff
<img width="0" height="0" class="mailtrack-img" alt="" style="display:flex" src=
-"https://mailtrack.io/trace/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
+"https://localhost/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
>
```

## Prerequisites

Apple Mail on macOS 10.11 - 11.x.

## Setup

### Recommended Installation via [Homebrew Cask](https://brew.sh) (private tap)

You can install `MailTrackerBlocker.pkg` directly from the [releases page](https://github.com/apparition47/MailTrackerBlocker/releases) but I strongly recommend installing as an Homebrew Cask for ease of updating.

```bash
$ brew install apparition47/tap/mailtrackerblocker
```

### To enable and use

1. Open Mail, goto `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`.
2. Tap on the `ⓧ` button to find out what was blocked.

⚠️ Disabling ["load remote content in messages"](https://www.imore.com/sites/imore.com/files/styles/xlarge/public/field/image/2019/07/mac-load-remote.jpg) with MailTrackerBlocker enabled is redundant; re-enable this option for the best experience.

### To uninstall

```bash
$ brew uninstall mailtrackerblocker
```

Or if you installed manually, quit Mail then delete `/Library/Mail/Bundles/MailTrackerBlocker.mailbundle`.



## Building from source

#### A. Makefile
```bash
git clone https://github.com/apparition47/MailTrackerBlocker.git
cd MailTrackerBlocker
make
```

#### B. Xcode

1. Give Xcode `Full Disk Access` from `System Preferences > Security & Privacy > Privacy > Full Disk Access` and add Xcode.
     * Required because the mailbundle needs to be installed into `/Library/Mail/Bundles`.
2. Open the Xcode project, hit build.


## [Credits](https://github.com/apparition47/MailTrackerBlocker/blob/master/Resources/ACKNOWLEDGEMENTS)

* [GPGMail](https://github.com/GPGTools/GPGMail) team for their work on Mail.app plugins
* [@dhh](https://github.com/dhh) for the [spy pixel tracker blocking list used in HEY](https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20)
* [@bitmanic](https://github.com/bitmanic) for the UI design


## [License](https://github.com/apparition47/MailTrackerBlocker/blob/master/LICENSE)

BSD-3.