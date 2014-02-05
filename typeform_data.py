#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright (C) 2014 Xavier Bruhiere
#
# Distributed under terms of the MIT license.


import os
import requests


typeform_api_url = 'https://api.typeform.com/api/v0/form'
typeform_id = 'o2AuWH'
api_key = os.environ.get('TYPEFORM_API_KEY', None)
completed = True

data = requests.get('/'.join([typeform_api_url, typeform_id]),
                    params={'key': api_key, 'completed': completed})

print data.text
