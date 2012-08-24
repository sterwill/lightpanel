#########################################################################
# Common include file for application Makefiles (adapted from Roku SDK)
#
# Makefile Usage:
# > make
# > make install
# > make remove
#
# to exclude certain files from being added to the zipfile during packaging
# include a line like this:ZIP_EXCLUDE= -x keys\*
# that will exclude any file who's name begins with 'keys'
# to exclude using more than one pattern use additional '-x <pattern>' arguments
# ZIP_EXCLUDE= -x \*.pkg -x storeassets\*
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################  

APPNAME = lightpanel
VERSION = 1.0

PKGREL = pkg
ZIPREL = out

ZIP_INCLUDES = images source/*.brs source/screens/*.brs manifest
ZIP_EXCLUDES = -x \*~

.PHONY: all $(APPNAME)

$(APPNAME): manifest
	@echo "Creating $(ZIPREL)/$(APPNAME).zip"

	@if [ -e "$(ZIPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(ZIPREL)/$(APPNAME).zip; \
	fi

	@if [ ! -d $(ZIPREL) ]; \
	then \
		mkdir -p $(ZIPREL); \
	fi

	@if [ ! -w $(ZIPREL) ]; \
	then \
		chmod 755 $(ZIPREL); \
	fi

	@if [ "$(IMPORTFILES)" ]; \
	then \
		mkdir $(APPSOURCEDIR)/common; \
		cp -f --preserve=ownership,timestamps --no-preserve=mode -v $(IMPORTFILES) $(APPSOURCEDIR)/common/; \
	fi \

	@zip -0 -r "$(ZIPREL)/$(APPNAME).zip" $(ZIP_INCLUDES) -i \*.png $(ZIP_EXCLUDES)
	@zip -9 -r "$(ZIPREL)/$(APPNAME).zip" $(ZIP_INCLUDES) -x \*.png $(ZIP_EXCLUDES)

	@echo "Done creating $(ZIPREL)/$(APPNAME).zip"

install: $(APPNAME)
	@if [ -z "$(ROKU_DEV_TARGET)" ]; \
	then \
		echo "Set the ROKU_DEV_TARGET environment variable to the hostname or IP of your device"; \
		exit 1; \
	fi
	 
	@echo "Installing $(APPNAME) to host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["

pkg: install
	@echo "Packaging $(APPNAME) on host $(ROKU_DEV_TARGET)"

	@if [ ! -d $(PKGREL) ]; \
	then \
		mkdir -p $(PKGREL); \
	fi

	@if [ ! -w $(PKGREL) ]; \
	then \
		chmod 755 $(PKGREL); \
	fi

	@read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep '^<font face=' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's#pkgs/##' | xargs -i curl -s -S -o $(PKGREL)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}
	
	@echo "Done packaging $(APPNAME) on host $(ROKU_DEV_TARGET)"
	
remove:
	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[["
