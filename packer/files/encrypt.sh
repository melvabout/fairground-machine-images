#!/bin/bash
for filename in ./secret/*.*; do
    sops -e -i $filename
done