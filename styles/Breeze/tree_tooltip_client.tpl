<!--
TeamSpeak 3 Client Tooltip Template

Copyright (c) 2009-2020 TeamSpeak Systems GmbH

The replaceable variables are embedded in "%%" like %%CLIENT_NAME%%. At this time you can also use
%%?CLIENT_NAME%% (note the question mark), which is a tiny "if"- query. Use it, to remove the whole
line, if a variable is empty or just "0".

Templates must be placed in in a sub folder named like the theme (e.g. "styles/example/").
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

<table>
    <tr>
        <td class="noborder avatar">%%?CLIENT_AVATAR%%</td>
        <td class="noborder">
            <table width="300">
                <tr>
                    <td class="label">%%TR_CLIENT_NAME%%:</td>
                    <td>
                        <img src="%%?CLIENT_COUNTRY_IMAGE%%" alt="" />&nbsp;&nbsp;
                        <span class="Highlight">%%CLIENT_NAME%%</span>
                        &nbsp;<span class="Highlight">[%%?CLIENT_CUSTOM_NICK_NAME%%]</span>
                    </td>
                </tr>
                <tr><td class="label">%%TR_CLIENT_DESCRIPTION%%:</td><td>%%?CLIENT_DESCRIPTION%%</td></tr>
                <tr>
                    <td class="label">%%TR_CLIENT_CONNECTED_SINCE%%:</td>
                    <td>%%CLIENT_CONNECTED_SINCE%%</td>
                </tr>
            </table>
        </td>
    </tr>
</table>
