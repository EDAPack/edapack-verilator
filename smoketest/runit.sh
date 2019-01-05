#!/bin/bash
#********************************************************************
#* runit.sh
#*
#* Smoke test for the EDAPack version of Verilator
#********************************************************************

function fail()
{
  echo "FAIL: verilator version ($tmpdir)" 
  exit 1
}

function try()
{
  $* > log 2>&1
  if test $? -ne 0; then 
    echo "Error log:"
    cat log
    fail
  fi
}

function note()
{
  echo "[$tool] Note: $*"
}

tool=verilator
smoketest_dir=$(dirname $0)
smoketest_dir=$(cd $smoketest_dir ; pwd)

edapack_verilator_dir=$(dirname $smoketest_dir)

tmpdir=`mktemp -d`
note "running test in $tmpdir"

try cd $tmpdir
try cp $smoketest_dir/top.v .
#test_fail $?

note "Running verilator"
try $edapack_verilator_dir/bin/verilator --cc --exe top.v
#test_fail $?

try cp $smoketest_dir/top.cc obj_dir

note "Compiling image"
try make VK_USER_OBJS=top.o -C obj_dir -f Vtop.mk Vtop

./obj_dir/Vtop > run.log 2>&1

if test $? -ne 0; then
  fail
fi

count=$(grep 'Hello World' run.log | wc -l)

note "Checking logfile"
if test $count -ne 1; then
  fail
fi

echo "PASS: verilator version"
rm -rf $tmpdir

