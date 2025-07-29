#!/bin/bash

# Git commit message checker for BBPS iOS SDK
# This script validates commit message format

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

error_msg="Aborting commit. Your commit message is invalid. See the example below:

feat(bbps): add new bill payment functionality
fix(utils): resolve payload validation issue
docs(readme): update installation instructions

The commit message should be structured as follows:
<type>[optional scope]: <description>

Where type can be: feat, fix, docs, style, refactor, test, chore"

if ! grep -qE "$commit_regex" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi