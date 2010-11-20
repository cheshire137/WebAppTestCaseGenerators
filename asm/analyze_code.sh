#!/bin/bash
find . -name \*.rb | xargs flog > flog_report.txt
echo "Generated flog_report.txt"
find . -name \*.rb | xargs flay > flay_report.txt
echo "Generated flay_report.txt"
find . -name \*.rb | xargs reek > reek_report.txt
echo "Generated reek_report.txt"
#mvim flog_report.txt flay_report.txt reek_report.txt
