#!/bin/bash
for filename in ./secret/*.*; do
    sops -d -i $filename
done