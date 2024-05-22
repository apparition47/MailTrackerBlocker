<p align="center"><img width="635" src="https://user-images.githubusercontent.com/3298414/121038136-00d2f780-c7eb-11eb-8e1a-d7d1fafc2e15.jpg"></p>

**MailTrackerBlocker** is a email tracker blocking plugin (mailbundle) for macOS Mail. [Email marketers and other interests often embed these trackers in HTML emails so they can track how often, when and where you open your emails.](https://notospypixels.com/) Find out who is tracking you and block spy pixels without needing to disable "load remote content in messages" so that you can browse your inbox privately with images displayed once again.


## Requirements

- macOS El Capitan 10.11 - Ventura 13 ([why not newer versions?](https://www.macrumors.com/2023/06/14/macos-sonoma-drops-legacy-mail-app-plug-ins/))
- Apple Mail


## Setup

### Installation

You can install `MailTrackerBlocker.pkg` directly from the [releases page](https://github.com/apparition47/MailTrackerBlocker/releases) or via [Homebrew Cask](https://brew.sh):

```bash
$ brew install mailtrackerblocker
```

### Usage

<details>
<summary><b>macOS 12, 13</b></summary>
<br>
1. Tap on the <strong>ⓧ</strong> button to find out what was blocked.
<br>
2. [Optional] Images are safe for viewing so to re-enable: from the Mail menu bar, open Settings > Privacy > disable <a href="https://techviral.net/wp-content/uploads/2021/11/Mail-Privacy-Protection.jpg">"Block All Remote Content"</a>.
</details>

<details>
<summary><b>macOS 10.11, 10.12, 10.13, 11</b></summary>
<br>
1. Tap on the <strong>ⓧ</strong> button to find out what was blocked.
<br>
2. [Optional] Images are safe for viewing so to re-enable: from the Mail menu bar, open Settings > Viewing > re-enable <a href="https://www.imore.com/sites/imore.com/files/styles/xlarge/public/field/image/2019/07/mac-load-remote.jpg">"Load remote content in messages"</a>.
</details>

<details open>
<summary><b>macOS 10.14, 10.15</b></summary>
<br>
1. Open Mail, goto `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`. Note that you'll need to do this again for each update.
<br>
2. Tap on the <strong>ⓧ</strong> button to find out what was blocked.
<br>
3. [Optional] Images are safe for viewing so to re-enable: from the Mail menu bar, open Settings > Viewing > re-enable <a href="https://www.imore.com/sites/imore.com/files/styles/xlarge/public/field/image/2019/07/mac-load-remote.jpg">"Load remote content in messages"</a>.
</details>


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

### Does this work with Mail Privacy Protection?

Yes, in some network environments (e.g. VPN) where Mail Privacy Protection doesn't work, MailTrackerBlocker will still block and identify trackers if you choose to "Load Remote Content".

Note: [Mail Privacy Protection's proxy will still fetch the tracker image, triggering the tracker after an unknown period of time](https://www.mailbutler.io/blog/news/why-apples-mail-privacy-protection-does-not-break-mailbutlers-tracking-feature/). In the period of time before this happens, if you open your email without MailTrackerBlocker, the proxy will fetch the tracking image and trigger the tracker at that moment still letting the tracker know your exact opening time.

### Why am I getting a "Incompatible Plug-ins Disabled" message after enabling?

Typically caused by a Mac migration or a restoration from backup. [Delete Mail's private plugin-ins dir (or DataVaults)](https://c-command.com/spamsieve/help/resetting-mail-s-privat) to fix this issue. This directory will safely and automatically be regenerated afterwards.

### Why is my Mail so slow?

This issue isn't related to MailTrackerBlocker but such problems can be resolved by doing a complete [Mailbox Rebuild](https://c-command.com/spamsieve/help/how-can-i-rebuild-apple) to force Mail to regenerate its indexes.


## Building from source

Building will automatically install a copy into your `/Library/Mail/Bundles/` dir so if you have a current installation from the public pkg installer, you'll need to remove it due to permissions: `$ rm -rf /Library/Bundles/MailTrackerBlocker.mailbundle`.

```bash
git clone https://github.com/apparition47/MailTrackerBlocker.git --recursive
cd MailTrackerBlocker
```

#### A. Make

To sign with your identity, edit the `Makefile` to specify your own `Developer ID Application` (used to sign the plugin binary [for macOS 11 and up]) and `Developer ID Installer` (used to sign the pkg) certificates. You can also comment out the top lines to disable signing.

To build binary, pkg and sign (if configured):

```bash
make all
open build/Release
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
* **[@raybrownco](https://github.com/raybrownco)** for the original UI design and icon
* **[GPGTools Team](https://gpgtools.org/)** for their open source GPGMail plugin from which MailTrackerBlocker is based on
* **[SpamSieve](https://c-command.com/spamsieve/)** for their Mail knowledgebase and troubleshooting manuals


## [License](https://github.com/apparition47/MailTrackerBlocker/blob/master/LICENSE)

BSD-3.
