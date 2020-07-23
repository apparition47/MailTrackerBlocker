# MailTrackerBlocker

MailTrackerBlocker is a macOS Apple Mail plugin (i.e. mailbundle) to block read trackers disguised as "spy pixels". 

Most commercial trackers can be reliably blocked through a blacklist of known URL patterns. Failing that, MailTrackerBlocker applies a generic regex filter for 1x1 images. [Read more about how email pixel tracking works.](https://www.gmass.co/blog/tracking-pixel-blockers/)

![](https://user-images.githubusercontent.com/3298414/88289106-b1e5b600-cd2f-11ea-8ba8-e8fa8ad70e78.png)

```diff
<img width="0" height="0" class="mailtrack-img" alt="" style="display:flex" src=
-"https://mailtrack.io/trace/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
+"https://localhost/mail/0eabccbe98c98e9b8e9a8b89eab89ce9ab89e8bc.png?u=1234567"
>
```

## Prerequisites

Only tested on Apple Mail 13.4 on macOS 10.15 Catalina.

## Setup

1. Goto https://github.com/apparition47/MailTrackerBlocker/releases
2. Download then open the `.pkg` to install.
3. In Xcode, open `Preferences > General > Manage Plug-ins... > check "MailTrackerBlocker.mailbundle" > Apply and Restart Mail`
4. Tap on the `🛑 #` button to find out what was blocked.

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

* Mail.app hooking from [GPGMail](https://github.com/GPGTools/GPGMail)
* [Tracker blocking list from @dhh](https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20)