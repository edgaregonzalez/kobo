# WARNING: LOTS of duplication here, needs cleanup!

{{- define "env_general" -}}
# Choose between http or https
- name: {{ .Values.general.externalScheme }}
  value: {{ .Values.general.externalScheme | quote }}
# The publicly-accessible domain where your KoBo Toolbox instance will be reached (e.g. example.com).
- name: PUBLIC_DOMAIN_NAME
  value: {{ .Values.general.externalDomain }}
# The private domain used in docker network. Useful for communication between containers without passing through
# a load balancer. No need to be resolved by a public DNS.
- name: INTERNAL_DOMAIN_NAME
  value: localhost
# The publicly-accessible subdomain for the KoBoForm form building and management interface (e.g. koboform).
- name: KOBOFORM_PUBLIC_SUBDOMAIN
  value: {{ .Values.kpi.subdomain }}
# The publicly-accessible subdomain for the KoBoCAT data collection and project management interface (e.g.kobocat).
- name: KOBOCAT_PUBLIC_SUBDOMAIN
  value: {{ .Values.kobocat.subdomain }}
# The publicly-accessible subdomain for the Enketo Express web forms (e.g. enketo).
- name: ENKETO_EXPRESS_PUBLIC_SUBDOMAIN
  value: {{ .Values.enketo.subdomain }}

# For now, you must set ENKETO_API_TOKEN, used by KPI and KoBoCAT, to the same
# value as ENKETO_API_KEY. Eventually, KPI and KoBoCAT will also read
# ENKETO_API_KEY and the duplication will no longer be necessary.
#  For a description of this setting, see "api key" here:
#  https://github.com/kobotoolbox/enketo-express/tree/master/config#linked-form-and-data-server.
- name: ENKETO_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-enketo
      key: apiKey
- name: ENKETO_API_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-enketo
      key: apiKey

# Canonically a 50-character random string. For Django 1.8.13, see https://docs.djangoproject.com/en/1.8/ref/settings/#secret-key and https://github.com/django/django/blob/4022b2c306e88a4ab7f80507e736ce7ac7d01186/django/core/management/commands/startproject.py#L29-L31.
# To generate a secret key in the same way as `django-admin startproject` you can run:
# docker-compose run --rm kpi python -c 'from django.utils.crypto import get_random_string; print(get_random_string(50, "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)"))'
- name: DJANGO_SECRET_KEY
  value: {{ randAlphaNum 50 | upper | quote }}

- name: ENKETO_ENCRYPTION_KEY
  value: {{ randAlphaNum 120 | upper | quote }}

# The initial superuser's username.
- name: KOBO_SUPERUSER_USERNAME
  value: {{ .Values.general.superUser.username | quote }}
# The initial superuser's password.
- name: KOBO_SUPERUSER_PASSWORD
  value: {{ .Values.general.superUser.password | quote }}

# The e-mail address where your users can contact you.
- name: KOBO_SUPPORT_EMAIL
  value: {{ .Values.general.supportEmail | quote }}
{{- end -}}

{{- define "env_mongo" -}}
- name: KOBO_MONGO_PORT
  value: '27017'
- name: KOBO_MONGO_HOST
  value: {{ .Release.Name }}-mongodb
- name: MONGO_INITDB_ROOT_USERNAME
  value: root
- name: MONGO_INITDB_ROOT_PASSWORD
  value: {{ .Values.mongodb.auth.rootPassword | quote }}
- name: MONGO_INITDB_DATABASE
  value: {{ .Values.mongodb.auth.database | quote }}
- name: KOBO_MONGO_USERNAME
  value: {{ .Values.mongodb.auth.username | quote }}
- name: KOBO_MONGO_PASSWORD
  value: {{ .Values.mongodb.auth.password | quote }}
{{- end -}}

{{- define "env_postgres" -}}
# These `KOBO_POSTGRES_` settings only affect the postgres container itself and the
# `wait_for_postgres.bash` init script that runs within the kpi and kobocat
# containers. To control Django database connections, please see the
# `DATABASE_URL` environment variable.
- name: POSTGRES_PORT
  value: '5432'
- name: POSTGRES_HOST
  value: {{ .Release.Name }}-postgresql
- name: POSTGRES_USER
  value: {{ .Values.postgresql.postgresqlUsername | quote }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.postgresql.postgresqlPassword | quote }}
- name: KC_POSTGRES_DB
  value: {{ .Values.postgresql.kobocatDatabase | quote }}
- name: KPI_POSTGRES_DB
  value: {{ .Values.postgresql.kpiDatabase | quote }}

# Postgres database used by kpi and kobocat Django apps
- name: KC_DATABASE_URL
  value: "postgis://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.kobocatDatabase }}"
- name: KPI_DATABASE_URL
  value: "postgis://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.kpiDatabase }}"
{{- end -}}

{{- define "env_redis" -}}
- name: REDIS_SESSION_URL
  value: "redis://:{{ .Values.redis.password }}@{{ .Release.Name }}-rediscache-master:6379/2"
- name: REDIS_PASSWORD
  value: {{ .Values.redis.password | quote }}
{{- end -}}

{{- define "env_enketo" -}}
- name: ENKETO_REDIS_MAIN_HOST
  value: {{ .Release.Name }}-redismain-master
- name: ENKETO_REDIS_CACHE_HOST
  value: {{ .Release.Name }}-rediscache-master
- name: ENKETO_LINKED_FORM_AND_DATA_SERVER_SERVER_URL
  value: kobo.domain.name
- name: ENKETO_LINKED_FORM_AND_DATA_SERVER_API_KEY
  value: {{ .Values.enketo.apiKey | quote }}
- name: ENKETO_SUPPORT_EMAIL
  value: {{ .Values.general.supportEmail }}
{{- end -}}

{{- define "env_externals" -}}
- name: GOOGLE_ANALYTICS_TOKEN
  value: {{ .Values.external.google.analyticsToken | quote }}
- name: KOBOCAT_RAVEN_DSN
  value: {{ .Values.external.ravenDSN.kobocat | quote }}
- name: KPI_RAVEN_DSN
  value: {{ .Values.external.ravenDSN.kpi | quote }}
- name: KPI_RAVEN_JS_DSN
  value: {{ .Values.external.ravenDSN.kpiJs | quote }}
{{- end -}}

{{- define "env_kobocat" -}}
- name: KOBOCAT_DJANGO_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: TEMPLATE_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: USE_X_FORWARDED_HOST
  value: 'False'

- name: DJANGO_SETTINGS_MODULE
  value: onadata.settings.kc_environ
- name: ENKETO_VERSION
  value: Express

- name: KOBOCAT_BROKER_URL
  value: redis://:{{ .Values.redis.password }}@{{ .Release.Name }}-redismain-master:6379/2

- name: KOBOCAT_CELERY_LOG_FILE
  value: /srv/logs/celery.log

- name: ENKETO_OFFLINE_SURVEYS
  value: 'True'

# Mongo credentials come from mongo.txt
- name: KOBOCAT_MONGO_HOST
  value: {{ .Release.Name }}-mongodb

- name: KOBOFORM_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kpi.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: KOBOFORM_INTERNAL_URL
  value: "http://localhost:8001"
- name: KOBOCAT_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kobocat.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: ENKETO_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.enketo.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: SESSION_COOKIE_DOMAIN
  value: ".{{ .Values.general.externalDomain }}"
- name: DJANGO_ALLOWED_HOSTS
  value: ".{{ .Values.general.externalDomain }} localhost"

# DATABASE
- name: DATABASE_URL
  value: "postgis://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.kobocatDatabase }}"
- name: POSTGRES_DB
  value: {{ .Values.postgresql.kobocatDatabase | quote }}

# OTHER
- name: KPI_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kpi.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: KPI_INTERNAL_URL
  value: "http://localhost:8000"
- name: DJANGO_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: RAVEN_DSN
  value: {{ .Values.external.ravenDSN.kobocat | quote }}
{{- end -}}

{{- define "env_kpi" -}}
- name: KPI_DJANGO_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: TEMPLATE_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: USE_X_FORWARDED_HOST
  value: 'False'

- name: ENKETO_VERSION
  value: Express
- name: KPI_PREFIX
  value: /
- name: KPI_BROKER_URL
  value: redis://:{{ .Values.redis.password }}@{{ .Release.Name }}-redismain-master:6379/1

- name: KPI_MONGO_HOST
  value: {{ .Release.Name }}-mongodb

- name: DJANGO_LANGUAGE_CODES
  value: en fr es ar zh-hans hi ku
- name: DKOBO_PREFIX
  value: 'False'
- name: KOBO_SURVEY_PREVIEW_EXPIRATION
  value: '24'
- name: SKIP_CELERY
  value: 'False'
- name: EMAIL_FILE_PATH
  value: ./emails
- name: SYNC_KOBOCAT_XFORMS_PERIOD_MINUTES
  value: '30'
- name: KPI_UWSGI_PROCESS_COUNT
  value: '2'
- name: KOBO_SUPPORT_URL
  value: http://support.kobotoolbox.org/

- name: KOBOFORM_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kpi.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: ENKETO_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.enketo.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: ENKETO_INTERNAL_URL
  value: "http://localhost:8005"
- name: KOBOCAT_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kobocat.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
- name: KOBOCAT_INTERNAL_URL
  value: "http://localhost:8001"
- name: SESSION_COOKIE_DOMAIN
  value: ".{{ .Values.general.externalDomain }}"
- name: DJANGO_ALLOWED_HOSTS
  value: ".{{ .Values.general.externalDomain }} localhost"

# DATABASE
- name: DATABASE_URL
  value: "postgis://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Release.Name }}-postgresql:5432/{{ .Values.postgresql.kpiDatabase }}"
- name: POSTGRES_DB
  value: {{ .Values.postgresql.kpiDatabase | quote }}

# OTHER
- name: DJANGO_DEBUG
  value: {{ .Values.general.debug | quote }}
- name: RAVEN_DSN
  value: {{ .Values.external.ravenDSN.kpi | quote }}
- name: RAVEN_JS_DSN
  value: {{ .Values.external.ravenDSN.kpiJs | quote }}
- name: KPI_URL
  value: "{{ .Values.general.externalScheme }}://{{ .Values.kpi.subdomain }}.{{ .Values.general.externalDomain }}{{ .Values.general.publicPort }}"
{{- end -}}

{{- define "env_smtp" -}}
- name: EMAIL_BACKEND
  value: django.core.mail.backends.smtp.EmailBackend
- name: EMAIL_HOST
  value: {{ .Values.smtp.host | quote }}
- name: EMAIL_PORT
  value: {{ .Values.smtp.port | quote }}
- name: EMAIL_HOST_USER
  value: {{ .Values.smtp.user | quote }}
- name: EMAIL_HOST_PASSWORD
  value: {{ .Values.smtp.password | quote }}
- name: EMAIL_USE_TLS
  value: {{ .Values.smtp.tls | quote }}
- name: DEFAULT_FROM_EMAIL
  value: {{ .Values.smtp.from | quote }}
{{- end -}}

{{- define "env_uwsgi" -}}
- name: {{ . }}_UWSGI_MAX_REQUESTS
  value: '512'
- name: {{ . }}_UWSGI_WORKERS_COUNT
  value: '2'
- name: {{ . }}_UWSGI_CHEAPER_RSS_LIMIT_SOFT
  value: '134217728'
- name: {{ . }}_UWSGI_CHEAPER_WORKERS_COUNT
  value: '1'
- name: {{ . }}_UWSGI_HARAKIRI
  value: '120'
- name: {{ . }}_UWSGI_WORKER_RELOAD_MERCY
  value: '120'
{{- end -}}
