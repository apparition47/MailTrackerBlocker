# MailTrackerBlocker [![Awesome Humane Tech](https://raw.githubusercontent.com/humanetech-community/awesome-humane-tech/main/humane-tech-badge.svg?sanitize=true)](https://github.com/humanetech-community/awesome-humane-tech)

MailTrackerBlocker is a plugin (mailbundle) for the default Mail app built-in to macOS. Email marketers and other interests often embed these trackers in HTML emails so they can track how often, when and where you open your emails. This plugin labels who is tracking you and strips out spy pixels out of the HTML before display, rendering the typical advice of **disabling "load remote content in messages" unnecessary**.

Browse your inbox privately with images displayed once again.

Be informed. [Say No To Spy Pixels](https://notospypixels.com/).

<p align="center"><img width="600" src="https://user-images.githubusercontent.com/3298414/121038136-00d2f780-c7eb-11eb-8e1a-d7d1fafc2e15.jpg"></p>

```diff
<a style="color: #770506;">
<img src="http://cdn.website.com/newsletter/logo.png" width="438" height="42" border="0" style="max-width: 90%; height: auto" alt="logo.png">
</a>

<br>
<a href="https://website.us5.list-manage.com/unsubscribe?u=abdef">Click here to unsubscribe</a> or <a href="https://website.us5.list-manage.com/profile?u=abdef">Update subscription preferences</a>

-<img width="0" height="0" class="mailtrack-img" alt="" style="display:flex" src="https://mailtrack.io/trace/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567">
```

## Prerequisites

Apple Mail on macOS 10.11 - 12.x.

⚠️ If you have macOS 12 and up, [Mail Privacy Protection](https://support.apple.com/en-ca/guide/mail/mlhl03be2866/mac) is recommended over MailTrackerBlocker for more complete privacy guards.


## Setup

### Installation

You can install `MailTrackerBlocker.pkg` directly from the [releases page](https://github.com/apparition47/MailTrackerBlocker/releases) or via [Homebrew Cask](https://brew.sh):

```bash
$ brew install mailtrackerblocker
```

### Usage

1. [Additional step for macOS 10.14, 10.15 only] Open Mail, goto `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`. Note that you'll need to do this again for each update.
2. Tap on the `ⓧ` button to find out what was blocked.

⚠️ Disabling ["load remote content in messages"](https://www.imore.com/sites/imore.com/files/styles/xlarge/public/field/image/2019/07/mac-load-remote.jpg) with MailTrackerBlocker enabled is redundant; re-enable this option for the best experience.


### To uninstall

If you installed with Homebrew:

```bash
$ brew uninstall mailtrackerblocker
```

If you installed the `pkg` manually:

```bash
osascript -e "quit app \"Mail\""
# plugin files
sudo rm -r /Library/Mail/Bundles/MailTrackerBlocker.mailbundle
sudo rm -r /Library/Application\ Support/com.onefatgiraffe/mailtrackerblocker
sudo pkgutil --forget com.onefatgiraffe.mailtrackerblocker
# user-generated settings
rm -r ~/Library/Containers/com.apple.mail/Data/Library/Application\ Support/com.onefatgiraffe.mailtrackerblocker
defaults delete com.apple.mail _mtb_IsAutoUpdateCheckAllowed
defaults delete com.apple.mail _mtb_IsFirstStartup
defaults delete com.apple.mail _mtb_LastUpdateCheckDate
```

## FAQ

### Why am I getting a "Incompatible Plug-ins Disabled" message after enabling?

Typically caused by Mac migration or restoration from backup. [Delete Mail's private plugin-ins dir (or DataVaults)](https://c-command.com/spamsieve/help/resetting-mail-s-privat) to fix this issue. This dir will automatically be regenerated afterwards.


## Building from source

Building will automatically install a copy into your `/Library/Mail/Bundles/` dir so if you have a current installation from the public pkg installer, you'll need to remove it due to permissions: `$ rm -rf /Library/Bundles/MailTrackerBlocker.mailbundle`.

```bash
git clone https://github.com/apparition47/MailTrackerBlocker.git --recursive
```

#### A. Make

You'll need to edit `Makefile` and specify your own `Developer ID Application` (used to sign the plugin binary [for macOS 11 and up]) and `Developer ID Installer` (used to sign the pkg) certificates.

```bash
cd MailTrackerBlocker

# build-only
make

# build, sign binary and make pkg
make all
```

#### B. Xcode

1. Give Xcode `Full Disk Access` from `System Preferences > Security & Privacy > Privacy > Full Disk Access` and add Xcode.
     * Required because the mailbundle needs to be installed into `/Library/Mail/Bundles`.
2. Open the Xcode project.
3. Change the Signing settings in `Signing & Capabilities` (macOS 11 and up: you'll need to use your own `Developer ID Application` certificate; below macOS 11: set it to none/don't sign) then hit build.
     * mac OS 11 and up: allow `Finder` access to allow Xcode to copy unsigned directly into sandboxed env


## [Credits](https://github.com/apparition47/MailTrackerBlocker/blob/master/Resources/ACKNOWLEDGEMENTS)

* MailTrackerBlocker project sponsors, donators and contributors
* **[@dhh](https://github.com/dhh)** for the [spy pixel tracker block list used in HEY](https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20)
* **[@leggett](https://github.com/leggett)** for his [Simplify Gmail blocklist](https://github.com/leggett/simplify-trackers)
* **[@raybrownco](https://github.com/raybrownco)** for the first UI design
* **[GPGTools Team](https://gpgtools.org/)** for making this possible with GPGMail and for their extensive work on Mail plugins


## [License](https://github.com/apparition47/MailTrackerBlocker/blob/master/LICENSE)

BSD-3.
