#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""The setup script."""

import os
from setuptools import setup, find_packages, find_namespace_packages

version = os.environ.get("package_version")

with open('README.md') as readme_file:
    readme = readme_file.read()

requirements = []
setup_requirements = ['pytest-runner']
test_requirements = ['pytest']

setup(
    author="Marcel Aldecoa",
    author_email='marcel.aldecoa@microsoft.com',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'Programming Language :: Python :: 3.6'
    ],
    description="The dataopslib library contains all the data quality and data transformation logic for the Adventure Works DataOps project.",
    install_requires=requirements,
    long_description=readme,
    long_description_content_type='text/markdown',
    include_package_data=True,
    keywords=[
        'dataopslib',
        'data_quality',
        'data_transformation'
    ],
    name='dataopslib',
    packages=['dataopslib'],
    setup_requires=setup_requirements,
    test_suite='tests',
    tests_require=test_requirements,
    url='https://dev.azure.com/csu-devsquad/advworks-dataops/_git/hol',
    version=version,
    python_requires='>=3.6'
)
