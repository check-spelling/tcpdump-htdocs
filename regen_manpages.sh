#!/bin/sh

# This script regenerates (updates but not commits) tcpdump, libpcap and
# tcpslice man pages for the www.tcpdump.org web-site. It is intended to be
# run in tcpdump-htdocs git repository clone with the source man pages
# available in ../tcpdump, ../libpcap and ../tcpslice git clones respectively.
# To make the source man pages available it is sufficient to have ./configure
# run successfully in each of those directories.
#
# This script has been tested to work on the following Linux systems:
#
# * Fedora 24, 25
# * Ubuntu 16.04, 18.04
#

MAN2HTML_PFX=/cgi-bin/man/man2html
WEBSITE_PFX=/manpages

# Fedora man2html prepends its HTML output with a Content-type header.
# Ubuntu man2html in addition to that adds the <!DOCTYPE ...> XML tag
# before the HTML. For portability strip both variants of the preamble.
stripContentTypeHeader()
{
	sed -n '/^<HTML><HEAD><TITLE>/,$p'
}

printSedFile()
{
	local mansection mantopic manfile

	# Fixup custom links.
	# Suppress some output difference between Fedora and Ubuntu versions of man2html.
	# Convert file:// schema hyperlinks to plain text.
	cat <<ENDOFFILE
s@<A HREF="$MAN2HTML_PFX">Return to Main Contents</A>@<A HREF="$WEBSITE_PFX">Return to Main Contents</A>@g
s@<A HREF="$MAN2HTML_PFX">man2html</A>@man2html@g
s@^<HTML><HEAD><TITLE>Man page of @<HTML><HEAD><TITLE>Manpage of @
s@</HEAD><BODY>@<LINK REL="stylesheet" type="text/css" href="../style_manpages.css">\n</HEAD><BODY>@
s@<H1>@<H1>Manpage of @
s@<A HREF="file://\(.*\)">\(.*\)</A>@\2@g
ENDOFFILE

	# Convert links to non-local pages to plain text.
	while read mansection mantopic; do
		echo "s@<A HREF=\"$MAN2HTML_PFX?${mansection}+${mantopic}\">$mantopic</A>@$mantopic@g"
	done <<ENDOFLIST
4P	tcp
4P	udp
4P	ip
4	pf
8	pfconfig
2	select
2	poll
1	autoconf
8	usermod
3	strerror
1	kill
1	stty
1	ps
3	strftime
4	bpf
4P	nit
2	epoll_wait
2	kqueue
2	socket
1	date
3	isatty
3	fileno
ENDOFLIST

	# Fixup links to local pages, part 1.
	while read mantopic manfile; do
		echo "s@<A HREF=\"${MAN2HTML_PFX}?${mantopic}\"@<A HREF=\"$manfile\"@g"
	done <<ENDOFLIST
7+pcap-linktype		$WEBSITE_PFX/pcap-linktype.7.html
7+pcap-tstamp		$WEBSITE_PFX/pcap-tstamp.7.html
7+pcap-filter		$WEBSITE_PFX/pcap-filter.7.html
5+pcap-savefile		$WEBSITE_PFX/pcap-savefile.5.html
1+tcpdump		$WEBSITE_PFX/tcpdump.1.html
1+tcpslice		$WEBSITE_PFX/tcpslice.1.html
ENDOFLIST

	# Fixup links to local pages, part 2.
	print3PCAPMap | while read mantopic manfile; do
		[ "$manfile" = "" ] && manfile=$mantopic
		manfile="${WEBSITE_PFX}/${manfile}.3pcap.html"
		# Two substitutions below make up for the new smartness added
		# in man2html-1.6-13.g.fc20.
		echo "s@<B><A HREF=\"$MAN2HTML_PFX?3PCAP+${mantopic}\">$mantopic</A></B>(3PCAP)@<B>$mantopic</B>(3PCAP)@g"
		echo "s@<A HREF=\"$MAN2HTML_PFX?3PCAP+${mantopic}\">$mantopic</A>(3PCAP)@$mantopic(3PCAP)@g"
		echo "s@$mantopic(3PCAP)@<A HREF='$manfile'>$mantopic</A>(3PCAP)@g"
		echo "s@<B>$mantopic</B>(3PCAP)@<A HREF='$manfile'><B>$mantopic</B></A>(3PCAP)@g"
	done
}

print3PCAPMap()
{
	cat <<ENDOFLIST
pcap
pcap_activate
pcap_breakloop
pcap_can_set_rfmon
pcap_close
pcap_compile
pcap_create
pcap_datalink
pcap_datalink_name_to_val
pcap_datalink_val_to_description				pcap_datalink_val_to_name
pcap_datalink_val_to_name
pcap_dispatch							pcap_loop
pcap_dump
pcap_dump_close
pcap_dump_file
pcap_dump_flush
pcap_dump_fopen							pcap_dump_open
pcap_dump_ftell
pcap_dump_ftell64						pcap_dump_ftell
pcap_dump_open
pcap_file
pcap_fileno
pcap_findalldevs
pcap_fopen_offline						pcap_open_offline
pcap_fopen_offline_with_tstamp_precision			pcap_open_offline
pcap_freealldevs						pcap_findalldevs
pcap_freecode
pcap_free_datalinks						pcap_list_datalinks
pcap_free_tstamp_types						pcap_list_tstamp_types
pcap_get_required_select_timeout
pcap_geterr
pcap_getnonblock						pcap_setnonblock
pcap_get_selectable_fd
pcap_get_tstamp_precision
pcap_inject
pcap_is_swapped
pcap_lib_version
pcap_list_datalinks
pcap_list_tstamp_types
pcap_lookupdev
pcap_lookupnet
pcap_loop
pcap_major_version
pcap_minor_version						pcap_major_version
pcap_next_ex
pcap_next							pcap_next_ex
pcap_offline_filter
pcap_open_dead
pcap_open_dead_with_tstamp_precision				pcap_open_dead
pcap_open_live
pcap_open_offline
pcap_open_offline_with_tstamp_precision				pcap_open_offline
pcap_perror							pcap_geterr
pcap_sendpacket							pcap_inject
pcap_set_buffer_size
pcap_set_datalink
pcap_setdirection
pcap_setfilter
pcap_set_immediate_mode
pcap_setnonblock
pcap_set_promisc
pcap_set_protocol_linux
pcap_set_rfmon
pcap_set_snaplen
pcap_set_timeout
pcap_set_tstamp_precision
pcap_set_tstamp_type
pcap_snapshot
pcap_stats
pcap_statustostr
pcap_strerror
pcap_tstamp_type_name_to_val
pcap_tstamp_type_val_to_description				pcap_tstamp_type_val_to_name
pcap_tstamp_type_val_to_name
ENDOFLIST
}

produceHTML()
{
	local infile=${1:?argument required}
	local sedfile="${2:?argument required}"
	local outfile=${3:?argument required}
	[ -s $infile ] || {
		echo "Skipped: $infile, which does not exist or is empty"
		return
	}
	# A possible alternative: mandoc -T html $infile > $outfile
	man2html -M $MAN2HTML_PFX $infile | stripContentTypeHeader | sed --file="$sedfile" > $outfile
	# If the output file is git-tracked and the new revision is different in
	# timestamp only, discard the new revision.
	git show $outfile >/dev/null 2>&1 || {
		echo "Updated but not in repository: $outfile"
		return
	}
	git diff $outfile | tail --lines +5 | egrep '^[-+]' | egrep -q -v '^[-+]Time: ' || {
		git checkout $outfile
		return
	}
	echo "Updated: $outfile"
}

produceTXT()
{
	local infile=${1:?argument required}
	local outfile=${2:?argument required}
	[ -s $infile ] || {
		echo "Skipped: $infile, which does not exist or is empty"
		return
	}
	man -E ascii $infile > $outfile
	git diff $outfile | egrep -q '^[-+]' && echo "Updated: $outfile"
}

known3PCAPFile()
{
	local f=`basename ${1:?argument required} .3pcap`
	local manfile mantopic
	print3PCAPMap | while read mantopic manfile; do
		if [ "${manfile:-$mantopic}" = "$f" ]; then
			# Cannot just return 0 or 1 because the while end of
			# the pipe may be in a sub-shell.
			echo 'yes'
			return
		fi
	done
	echo 'no'
}

updateOutputFiles()
{
	which man2html >/dev/null 2>&1 || {
		echo "man2html must be installed to proceed"
		exit 1
	}

	# $COLUMNS doesn't always work
	local cols=`stty size | cut -d' ' -f2`
	if [ "$cols" != "80" ]; then
		echo "This terminal must be 80 ($cols right now) columns wide"
		exit 1
	fi

	local sedfile="`mktemp --tmpdir manpages_sedfile.XXXXXX`"
	printSedFile > "$sedfile"

	produceTXT ../libpcap/pcap-filter.manmisc manpages/pcap-filter.7.txt
	produceTXT ../libpcap/pcap-linktype.manmisc manpages/pcap-linktype.7.txt
	produceTXT ../libpcap/pcap-savefile.manfile manpages/pcap-savefile.5.txt
	produceTXT ../libpcap/pcap-tstamp.manmisc manpages/pcap-tstamp.7.txt

	produceHTML ../libpcap/pcap-filter.manmisc "$sedfile" manpages/pcap-filter.7.html
	produceHTML ../libpcap/pcap-linktype.manmisc "$sedfile" manpages/pcap-linktype.7.html
	produceHTML ../libpcap/pcap-savefile.manfile "$sedfile" manpages/pcap-savefile.5.html
	produceHTML ../libpcap/pcap-tstamp.manmisc "$sedfile" manpages/pcap-tstamp.7.html

	for f in ../libpcap/*.3pcap; do
		[ "`known3PCAPFile $f`" = 'no' ] && echo "WARNING: file $f is not in the 3PCAP map"
	done

	for f in ../libpcap/*.3pcap ../libpcap/pcap-config.1 ../tcpdump/tcpdump.1 ../tcpslice/tcpslice.1; do
		produceTXT $f manpages/`basename $f`.txt
		produceHTML $f "$sedfile" manpages/`basename $f`.html
	done

	rm -f "$sedfile"
}

updateOutputFiles
