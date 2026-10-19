"""WSGI entry point: usecallmanager's visual voicemail plus our contacts."""

from flask import Flask, Response

import contacts
import messages

application = Flask(__name__)
application.register_blueprint(contacts.blueprint)
application.register_blueprint(messages.blueprint)


@application.route("/")
def index():
    return Response("", mimetype="text/plain"), 200
