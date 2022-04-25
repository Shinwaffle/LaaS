set -e
# matches any ip that is in the 10.2.0.0 network
# matches 10.2.69.69 or 10.2.155.69
# it will also much anything like 10.2.699.699
# but it is coming from ss, so it wont output
# numbers like that. if it did that is a bug
# report and a half!
ss -a | egrep "10\.2\..{1,3}\..{1,3}"
