#! /usr/bin/perl

use warnings;
use strict;
use Carp;

sub licenseFileToVar($$) {
  my ($var,$file)=@_;

  my $ret;


  open(IN, $file) or croak;
  my $l = join("", <IN>);
  $l =~ s/\r//g;
  $l =~ s/\f//g;
  $l =~ s/\"/\\\"/g;

  $l = join("\\n\"\n\t\"",split(/\n/, $l));

  return qq!static const char *${var} = \n\t\"! . $l . "\";\n\n\n";
}

sub printGuarded($$$) {
  my ($F, $S, $Guard)=@_;
  
  if ($Guard) {
    print $F "#ifdef " . $Guard . "\n";
  }
  print $F $S;
  
  if ($Guard) {
    print $F "#endif\n";
  }
}


open(my $F, "> ../src/mumble/licenses.h");
binmode $F; # Ensure consistent file endings across platforms

print $F "/*\n";
print $F " * This file was auto-generated by scripts/mklic.pl\n";
print $F " * DO NOT EDIT IT MANUALLY\n";
print $F " */\n";
print $F "#ifndef MUMBLE_MUMBLE_LICENSES_H_\n";
print $F "#define MUMBLE_MUMBLE_LICENSES_H_\n";
print $F "\n";
print $F "#include <QtGlobal>\n\n";

print $F licenseFileToVar("licenseMumble", "../LICENSE");

# List of 3rd party licenses  [<variableName>, <pathToLicenseFile>, <DisplayName>, <URL>]
my @thirdPartyLicenses = (
    ["licenseCELT", "../celt-0.11.0-src/COPYING", "CELT", "http://www.celt-codec.org/"],
    ["licenseOpus", "../opus-src/COPYING", "Opus", "http://www.opus-codec.org/"],
    ["licenseSPEEX", "../speex/COPYING", "Speex", "http://www.speex.org/"],
    ["licenseOpenSSL", "../3rdPartyLicenses/openssl_license.txt", "OpenSSL", "http://www.openssl.org/"],
    ["licenseLibsndfile", "../3rdPartyLicenses/libsndfile_license.txt", "libsndfile", "http://www.mega-nerd.com/libsndfile/"],
    ["licenseOgg", "../3rdPartyLicenses/libogg_license.txt", "libogg", "http://www.xiph.org/"],
    ["licenseVorbis", "../3rdPartyLicenses/libvorbis_license.txt", "libvorbis", "http://www.xiph.org/"],
    ["licenseFLAC", "../3rdPartyLicenses/libflac_license.txt", "libFLAC", "http://flac.sourceforge.net/"],
    ["licenseMachOverride", "../3rdPartyLicenses/mach_override_license.txt", "mach_override", "https://github.com/rentzsch/mach_star", "Q_OS_MAC"],
    ["licenseQtTranslations", "../src/mumble/qttranslations/LICENSE",
    "Additional Qt translations", "https://www.virtualbox.org/ticket/2018", "USING_BUNDLED_QT_TRANSLATIONS"],
    ["licenseFilterSvg", "../icons/Filter.txt", "Filter.svg icon", "https://commons.wikimedia.org/wiki/File:Filter.svg"],
    );

# Print 3rd party licenses
foreach (@thirdPartyLicenses) {
    printGuarded($F, licenseFileToVar(@$_[0], @$_[1]), @$_[4]);
}

# Print list of 3rd party license references
print $F "static const char *licenses3rdParty[] = {\n";
foreach (@thirdPartyLicenses) {
    printGuarded($F, "\t" . @$_[0] . ", \n", @$_[4]);
}

print $F "\t0\n";
print $F "};\n\n\n";

# Print list of 3rd party names
print $F "static const char *licenses3rdPartyNames[] = {\n";
foreach (@thirdPartyLicenses) {
    printGuarded($F, "\t\"" . @$_[2] . "\",\n", @$_[4]);
}

print $F "\t0\n";
print $F "};\n\n\n";

# Print list of 3rd party urls
print $F "static const char *licenses3rdPartyURLs[] = {\n";
foreach (@thirdPartyLicenses) {
    printGuarded($F, "\t\"" . @$_[3] . "\",\n", @$_[4]);
}

print $F "\t0\n";
print $F "};\n";
print $F "\n";
print $F "#endif\n";

close($F);
