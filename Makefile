PROJECT = MailTrackerBlocker
TARGET = MailTrackerBlocker
PRODUCT = MailTrackerBlocker.mailbundle
VPATH = build/Release

all: clean unsigntool $(PRODUCT) pack

$(PRODUCT): Source/* Resources/* Resources/*/* MailTrackerBlocker.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -target $(TARGET) build $(XCCONFIG)

test:
	@xcodebuild -project $(PROJECT).xcodeproj -scheme $(TARGET) -resultBundlePath TestResults INSTALL_MAILTRACKERBLOCKER=0 CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO test

pack:
	pkgbuild $(VPATH)/Core.pkg \
		--install-location /Library/Application\ Support/com.onefatgiraffe/mailtrackerblocker \
		--scripts Packaging \
		--identifier com.onefatgiraffe.mailtrackerblocker \
		--root $(VPATH) \
		--filter ".pkg|.dSYM|.zip"
	cp Packaging/distribution.xml $(VPATH)/
	productbuild --resources Packaging/Resources/ --distribution $(VPATH)/distribution.xml --package-path $(VPATH)/ $(VPATH)/$(TARGET)-unsigned.pkg
	productsign --sign "Developer ID Installer: One Fat Giraffe (CW298N32P4)" $(VPATH)/$(TARGET)-unsigned.pkg $(VPATH)/$(TARGET).pkg

clean:
	rm -rf "./build"

unsigntool:
	make -C unsign ARCHS="-arch x86_64"
	mkdir -p $(VPATH)
	mv unsign/unsign $(VPATH)/
	codesign --options=runtime -s "Developer ID Application: One Fat Giraffe (CW298N32P4)" $(VPATH)/unsign