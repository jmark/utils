#!/usr/bin/sh
perl -MFile::Find=find -MFile::Spec::Functions -Tlw -e 'find { wanted => sub { print canonpath $_ if /\.pm\z/ }, no_chdir => 1 }, @INC';
