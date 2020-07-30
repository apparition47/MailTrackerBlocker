# MailTrackerBlocker

MailTrackerBlocker is a macOS Apple Mail plugin (i.e. mailbundle) to block read trackers disguised as "spy pixels". 

Most commercial trackers can be reliably blocked through a blacklist of known URL patterns. Failing that, MailTrackerBlocker applies a generic regex filter for 1x1 images. [Read more about how email pixel tracking works.](https://www.gmass.co/blog/tracking-pixel-blockers/)

![](https://user-images.githubusercontent.com/3298414/88930093-f89a5980-d2b5-11ea-85f6-37020305a450.png)

```diff
<img width="0" height="0" class="mailtrack-img" alt="" style="display:flex" src=
-"https://mailtrack.io/trace/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
+"https://localhost/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
>
```

## Prerequisites

Only tested on Apple Mail 13.4 on macOS 10.15 Catalina.

## Setup

1. Download and install the latest `.pkg` from the [releases page](https://github.com/apparition47/MailTrackerBlocker/releases).
2. Open Mail, goto `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`.
3. Tap on the `ⓧ #` button to find out what was blocked.

You can now reenable "load remote content in messages" if you had it disabled before using MailTrackerBlocker.

### Uninstall

Delete `/Library/Mail/Bundles/MailTrackerBlocker.mailbundle`.

## Building from source

#### A. Makefile
```bash
git clone https://github.com/apparition47/MailTrackerBlocker.git
cd MailTrackerBlocker
make
```

#### B. Xcode

1. Give XCode `Full Disk Access` from `System Preferences > Security & Privacy > Privacy > Full Disk Access` and add XCode.
     * Need this because the plugin needs to be installed into the Mail Apps bundles at `~/Library/Mail/Bundles`.
2. Open the Xcode project, hit build.


## Credits

* [GPGMail](https://github.com/GPGTools/GPGMail) team for their work on Mail.app plugins
* [@dhh](https://github.com/dhh) for the [spy pixel tracker blocking list used in HEY](https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20)
* [@bitmanic](https://github.com/bitmanic) for the UI design