<!--
TeamSpeak 3 Channel Tooltip Template

Copyright (c) 2009-2020 TeamSpeak Systems GmbH

The replaceable variables are embedded in "%%" like %%CHANNEL_NAME%%. At this time you can also use
%%?CHANNEL_NAME%% (note the question mark), which is a tiny "if"- query. Use it, to remove the whole
line, if a variable is empty or just "0".

Templates must be placed in in a sub folder named like the theme (e.g. "styles/example/").

Predefined values have to be inside the html comment-tag to make sure that they will be parsed
before the replacing begins!

Options (remove the "#" to enable):

#%%IMAGES_MAX_WIDTH%%256
#%%IMAGES_MAX_HEIGHT%%256

Replaceable variables for channels:

CHANNEL_NAME
CHANNEL_ID
CHANNEL_TOPIC
CHANNEL_MAXCLIENTS
CHANNEL_MAXFAMILYCLIENTS
CHANNEL_NEEDED_TALK_POWER
CHANNEL_ORDER
CHANNEL_CODEC
CHANNEL_CODEC_BITRATE
CHANNEL_FLAGS
CHANNEL_SUBSCRIPTION
CHANNEL_CLIENTS_COUNT
CHANNEL_VOICE_DATA_ENCRYPTED
CHANNEL_VOICE_DATA_ENCRYPTED_FLAG
CHANNEL_DESCRIPTION
CHANNEL_ICON
PLUGIN_INFO_DATA
IMAGES_MAX_WIDTH
TEMP_CHANNEL_DELETE_DELAY
TEMP_CHANNEL_TIME_TO_DELETE
-->
<style type="text/css">
    /* Breeze Dark: dark tooltip background */
    html, body {
        background-color: #232629 !important;
        color: #eff0f1 !important;
        margin: 0;
        padding: 6px;
    }

    table, table#info {
        border-collapse: collapse;
        border-spacing: 0;
        width: 100%;
        background-color: #232629;
    }

    td {
        padding: 4px 8px 4px 2px;
        white-space: nowrap;
        vertical-align: top;
        color: #eff0f1;
    }

    td.label {
        font-weight: bold;
        color: #bdc3c7 !important;   /* Breeze: dimmed label */
        padding-right: 15px;
    }

    td.noborder {
        padding: 0 6px 0 0;
    }

    td.avatar {
        vertical-align: top;
    }

    /* Breeze blue as accent */
    .Highlight {
        color: #3daee9 !important;
        font-weight: bold;
    }

    /* Regular values */
    td.Value {
        color: #eff0f1 !important;
    }

    /* Breeze neutral / warning */
    .Important {
        color: #f67400 !important;
        font-weight: bold;
    }

    .Active   { color: #27ae60 !important; }
    .Inactive { color: #7f8c8d !important; }

    a { color: #3daee9; text-decoration: none; }
    hr { color: #4d5257; background-color: #4d5257; }
</style>

<table id="info">
    <tr><td class="label">%%TR_CHANNEL_NAME%%:</td><td class="Highlight">%%CHANNEL_NAME%%</td></tr>
    <tr><td class="label">%%?TR_CHANNEL_TOPIC%%:</td><td>%%?CHANNEL_TOPIC%%</td></tr>
    <tr><td class="label">%%TR_CHANNEL_CODEC%%:</td><td>%%CHANNEL_CODEC%%</td></tr>
    <tr><td class="label">%%TR_CHANNEL_CODEC_QUALITY%%:</td><td>%%CHANNEL_CODEC_QUALITY%%</td></tr>
    <tr><td class="label">%%?TR_CHANNEL_FLAGS%%:</td><td class="Highlight">%%?CHANNEL_FLAGS%%</td></tr>
    <tr><td class="label">%%?TR_CHANNEL_CLIENTS_COUNT%%:</td><td>%%?CHANNEL_CLIENTS_COUNT%% / %%CHANNEL_FLAG_MAXCLIENTS%%</td></tr>
    <tr><td class="label">%%?TR_CHANNEL_NEEDED_TALK_POWER%%:</td><td class="Important">%%?CHANNEL_NEEDED_TALK_POWER%%</td></tr>
    <tr><td class="label">%%TR_CHANNEL_SUBSCRIPTION%%:</td><td>%%CHANNEL_SUBSCRIPTION%%</td></tr>
    <tr><td class="label">%%TR_CHANNEL_VOICE_DATA_ENCRYPTED%%:</td><td>%%CHANNEL_VOICE_DATA_ENCRYPTED%%</td></tr>
    %%?PLUGIN_INFO_DATA%%
</table>

<p class="Important" style="margin-top: 4px;">%%?TEMP_CHANNEL_TIME_TO_DELETE%%</p>
