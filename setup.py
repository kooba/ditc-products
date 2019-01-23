#!/usr/bin/env python
from setuptools import find_packages, setup

setup(
    name='ditc-products',
    version='0.0.1',
    description='Store and serve products',
    packages=find_packages("products"),
    package_dir={'': 'products'},
    install_requires=[
        "nameko==2.11.0",
        "redis==2.10.5",
        "marshmallow==2.9.1",
    ],
    extras_require={
        'dev': [
            "black==18.9b0",
            "behave==1.2.6",
            "coverage==4.5.2",
            "flake8==3.6.0",
            "pytest==4.0.1",
        ],
    },
    zip_safe=True
)
