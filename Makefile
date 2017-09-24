NAME=siege
VERSION=4.0.4
ITERATION=1.lru
PREFIX=/usr/local
LICENSE=GPL-3.0
VENDOR="Jeffrey Fulmer"
MAINTAINER="Ryan Parman"
DESCRIPTION="Siege is an open source regression test and benchmark utility."
URL=https://www.joedog.org/siege-home/
ACTUALOS=$(shell osqueryi "select * from os_version;" --json | jq -r ".[].name")
EL=$(shell if [[ "$(ACTUALOS)" == "Amazon Linux AMI" ]]; then echo alami; else echo el; fi)
RHEL=$(shell [[ -f /etc/centos-release ]] && rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean install-deps compile install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "OS:          $(ACTUALOS)"
	@ echo "EL:          $(EL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* siege*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum install -y \
		autoconf \
		automake \
		gcc \
		make \
		openssl-devel \
		zlib-devel \
	;

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	git clone -q -b v$(VERSION) https://github.com/JoeDog/siege.git --depth=1;
	cd siege && \
		utils/bootstrap && \
		./configure --with-ssl=/usr/include/openssl && \
		make \
	;

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	cd siege && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION);

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG.txt \
		--rpm-dist $(EL)$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
		usr/local/etc \
		usr/local/share \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	[[ -d /vagrant/repo ]] && mv *.rpm /vagrant/repo/
