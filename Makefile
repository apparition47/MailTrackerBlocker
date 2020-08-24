PROJECT = MailTrackerBlocker
TARGET = MailTrackerBlocker
PRODUCT = MailTrackerBlocker.mailbundle
VPATH = build/Release

all: $(PRODUCT)

$(PRODUCT): Source/* Resources/* Resources/*/* MailTrackerBlocker.xcodeproj
	@xcodebuild -project $(PROJECT).xcodeproj -target $(TARGET) build $(XCCONFIG)
	zip -r -9 $(VPATH)/$(PRODUCT).zip $(VPATH)/$(PRODUCT)
	pkgbuild --install-location /private/tmp/MailTrackerBlocker-Installation-Temp --scripts Packaging --identifier com.onefatgiraffe.mailtrackerblocker --root $(VPATH) --filter ".pkg|.dSYM|.zip" $(VPATH)/$(TARGET)-unsigned.pkg

sign:
	productsign --sign "Developer ID Installer: One Fat Giraffe (CW298N32P4)" $(VPATH)/$(TARGET)-unsigned.pkg $(VPATH)/$(TARGET).pkg

clean:
	rm -rf "./build"
