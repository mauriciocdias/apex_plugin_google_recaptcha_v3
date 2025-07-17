prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.05.24'
,p_release=>'18.2.0.00.12'
,p_default_workspace_id=>2092032099834462
,p_default_application_id=>50500
,p_default_owner=>'SILICON'
);
end;
/
prompt --application/shared_components/plugins/item_type/br_google_recaptcha_v3_plugin
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(10280312266942437418)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'BR.GOOGLE_RECAPTCHA_V3_PLUGIN'
,p_display_name=>'Google reCaptcha v3 APEX 5'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'--==========================================================',
'-- This function renders the Google reCaptcha version 3 item ',
'--==========================================================',
'function render_recaptcha (p_item                in apex_plugin.t_page_item,',
'                           p_plugin              in apex_plugin.t_plugin,',
'                           p_value               in varchar2,',
'                           p_is_readonly         in boolean,',
'                           p_is_printer_friendly in boolean) return apex_plugin.t_page_item_render_result is',
'',
'  l_name            varchar2(30);',
'  l_public_key      varchar2(4000) := p_plugin.attribute_01;',
'  l_url_js          varchar2(4000) := nvl(p_plugin.attribute_07,''https://www.google.com/recaptcha/api.js'');',
'  ',
'  l_button_selector varchar2(4000) := p_item.attribute_01;',
'  l_lang            varchar2(255)  := nvl(p_item.attribute_05, ''en'');',
'  ',
'  l_result     apex_plugin.t_page_item_render_result;',
'',
'begin',
'  -- Check plug-in configuration',
'  if l_public_key is null then',
'    raise_application_error(-20999, ''No Public Key has been set for the reCaptcha plug-in! You can get one at https://www.google.com/recaptcha/admin/create'');',
'  end if;',
'',
'  -- Captcha page item will be a single value field',
'  l_name := apex_plugin.get_input_name_for_page_item (p_is_multi_value => false );',
'',
'  htp.p(''<input type="hidden" id="''||p_item.name||''" name="''||p_item.name||''" class="t-Form-input--noLabel" value="">''); ',
'',
'  htp.p(''<script type="text/javascript">',
'    document.addEventListener("DOMContentLoaded", function() {',
'    if (typeof $ === "function") {',
'    //    $(document).on("apexbeforepagesubmit", function(event, data) { -- dont work with -> reload on submit - only for success',
'    ',
'       ',
'        $(''''''||l_button_selector||'''''').on("click", function(event) {',
'        //apex.jQuery(''''''||l_button_selector||'''''').on("click", function(event){',
'        //event.preventDefault(); // impede o submit imediato',
'        e = event || window.event;',
'        e.preventDefault();',
'        var recaptchaItem = "''||p_item.name||''";',
'        var v_button_id = $(this).attr(''''id'''');',
'        ',
'        // Executa o reCAPTCHA v3',
'        grecaptcha.ready(function() {',
'            grecaptcha.execute("''||l_public_key||''", { action: "submit" }).then(function(token) {',
'            $s(recaptchaItem, token); // coloca o token no item',
unistr('            // Ap\00F3s valor definido, reenvia o formul\00E1rio.'),
'            let v_json_submit =  {',
'                                "request": v_button_id,',
'                                "showWait": true,',
'                                };  ',
'            apex.page.submit(v_json_submit); ',
'',
'              });',
'        });',
'    });     ',
'    }',
'     else {',
'      console.error("jQuery not available");',
'    }',
'});',
'</script>'');',
'',
'  htp.p(''<script src="''||l_url_js||''?render=''||l_public_key||''&hl='' || l_lang||''"></script>'');',
'  ',
'  -- Set field as not navigable',
'  l_result.is_navigable := false;',
'',
'  -- if in debug mode, debugging information will displayed in the debug window',
'  apex_plugin_util.debug_page_item(p_plugin, p_item, p_value, p_is_readonly, p_is_printer_friendly);',
'',
'  return l_result;',
'end render_recaptcha;',
'',
'',
'--=====================================================================================',
'-- This fucntion validates the reCaptcha response value against the Google web service.',
'--=====================================================================================',
'function validate_recaptcha (p_item   in apex_plugin.t_page_item,',
'                             p_plugin in apex_plugin.t_plugin,',
'                             p_value  in varchar2) return apex_plugin.t_page_item_validation_result is',
'',
'  l_private_key      varchar2(4000) := p_plugin.attribute_02;',
'  l_wallet_path      varchar2(4000) := p_plugin.attribute_03;',
'  l_wallet_pwd       varchar2(4000) := p_plugin.attribute_04;',
'  l_url_verify       varchar2(4000) := nvl(p_plugin.attribute_05,''https://google.com/recaptcha/api/siteverify'');',
'  l_ip_address_func  varchar2(4000) := nvl(p_plugin.attribute_06,''owa_util.get_cgi_env(''''REMOTE_ADDR'''')''); ',
'  ',
'  ',
'  l_threshold       number         := nvl(to_number(p_item.attribute_02, ''999D99'', ''NLS_NUMERIC_CHARACTERS=''''.,''''''), 0.5);',
'  l_error_msg       varchar2(4000) := p_item.attribute_03;',
'  l_error_location  varchar2(100)  := nvl(p_item.attribute_04,''INLINE_IN_NOTIFICATION'');',
'  l_score number; ',
'  l_success boolean;',
'  ',
'  l_ip_address      varchar2(100);',
'  l_parm_name_list  apex_application_global.vc_arr2;',
'  l_parm_value_list apex_application_global.vc_arr2;',
'  l_rest_result     varchar2(32767);',
'',
'  l_result          apex_plugin.t_page_item_validation_result;',
'  ',
'begin',
'',
'-- Check if plug-in private key is set',
'  if l_private_key is null then',
'    raise_application_error(-20999, ''No Private Key has been set for the reCaptcha plug-in! Get one at https://www.google.com/recaptcha/admin/create'');',
'  end if;',
'',
'  if p_value is null then --does reCaptcha v3 generate the token?',
'    l_result.message := l_error_msg;',
'    return l_result;',
'  end if;',
'  ',
'  l_ip_address :=apex_plugin_util.get_plsql_expression_result(l_ip_address_func);',
'  apex_debug.INFO (''reCaptcha v3 Client IP =''|| l_ip_address);     ',
'  apex_debug.INFO (''l_error_location =''|| l_error_location); ',
'  ',
'',
'  -- See https://code.google.com/apis/recaptcha/docs/verify.html',
'  l_parm_name_list (1) := ''secret'';',
'  l_parm_value_list(1) := l_private_key;',
'  l_parm_name_list (2) := ''response'';',
'  l_parm_value_list(2) := p_value; ',
'  l_parm_name_list (3) := ''remoteip'';',
'  l_parm_value_list(3) := l_ip_address; ',
'',
'  -- Set web service header rest request',
'  apex_web_service.g_request_headers(1).name  := ''Content-Type'';',
'  apex_web_service.g_request_headers(1).value := ''application/x-www-form-urlencoded'';',
'',
'  -- Call the reCaptcha REST service to verify the response against the private key',
'  l_rest_result := wwv_flow_utilities.clob_to_varchar2(',
'                       apex_web_service.make_rest_request(',
'                           p_url         => l_url_verify,',
'                           p_http_method => ''POST'',',
'                           p_parm_name   => l_parm_name_list,',
'                           p_parm_value  => l_parm_value_list,',
'                           p_wallet_path => l_wallet_path,',
'                           p_wallet_pwd  => l_wallet_pwd ',
'                       ));',
'',
'  -- Delete the request header',
'  apex_web_service.g_request_headers.delete;',
'',
'  -- Check the HTTPS status call',
'  case',
'    when apex_web_service.g_status_code in (''200'') then -- successful call ',
'  ',
'        apex_json.parse(l_rest_result);    ',
'        l_success := apex_json.get_boolean(p_path => ''success''); ',
'        l_score := apex_json.get_number(p_path => ''score'');',
'    ',
'        if l_success and l_score >= l_threshold then',
'          l_result.message := '''';',
'          APEX_UTIL.SET_SESSION_STATE (p_name => p_item.name, p_value => ''RECAPTCHA-V3-SUCCESS'');',
'          apex_debug.INFO (''reCaptcha v3 success score=''|| l_score);     ',
'        else',
'          l_result.message := l_error_msg ||'' ( '' || l_score || case when apex_json.get_count(p_path => ''"error-codes"'') > 0 then '' - '' ||  apex_json.get_VARCHAR2(p_path=>''"error-codes"[%d]'',p0=> 1) else null end ||'')'';      ',
'          l_result.display_location := l_error_location;',
'          APEX_UTIL.SET_SESSION_STATE (p_name => p_item.name, p_value => ''RECAPTCHA-V3-FAILED'');',
'          apex_debug.INFO (l_result.message);',
'          apex_debug.INFO (''reCaptcha v3 return=''||l_rest_result);',
'        end if;',
'',
'  else -- unsucessful call',
'    l_result.message := ''reCaptcha HTTPS request status : '' || apex_web_service.g_status_code;',
'    l_result.display_location := l_error_location;',
'    APEX_UTIL.SET_SESSION_STATE (p_name => p_item.name, p_value => ''RECAPTCHA-V3-UNSUCESSFUL-CALL'');',
'  end case;',
' ',
'',
'  -- if in debug mode, debugging information will displayed in the debug window',
'  apex_plugin_util.debug_page_item(p_plugin, p_item, p_value, true, false);',
'  ',
'  return l_result;',
'end validate_recaptcha;',
''))
,p_api_version=>1
,p_render_function=>'render_recaptcha'
,p_validation_function=>'validate_recaptcha'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_about_url=>'https://github.com/mauriciocdias/apex_plugin_google_recaptcha_v3'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Author:',
unistr('Maur\00EDcio Carlos Dias '),
'mauriciocdias@gmail.com',
'16-JUL-2025',
'',
'This plugin implements Google reCAPTCHA v3.',
'',
'It was inspired by Mohamed Zebib''s Google reCAPTCHA v2 plugin: https://apex.world/ords/r/apex_world/apex-world/plug-in-details?p710_plg_int_name=ca.mzebib.captcha2&clear=710',
''))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10280312503996437431)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Public Key'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'your-public-key'
,p_display_length=>50
,p_is_translatable=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The provided default Public Key a google Public Key for testing purpose:',
'6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'))
,p_help_text=>'Public Key required to render the reCaptcha. Get a key for your domain at <a href="https://www.google.com/recaptcha/admin/create" target="_blank">https://www.google.com/recaptcha/admin/create</a>.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10280312891465437441)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Private Key'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'your-private-key'
,p_display_length=>50
,p_is_translatable=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The provided default Private Key a google Private Key for testing purpose:',
'6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'))
,p_help_text=>'Private Key required to verify the reCaptcha value. Get a key for your domain at <a href="https://www.google.com/recaptcha/admin/create" target="_blank">https://www.google.com/recaptcha/admin/create</a>.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10280313222038437441)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Wallet Path'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'file:/u01/app/oracle/wallets/oracle'
,p_display_length=>50
,p_is_translatable=>true
,p_examples=>'file:D:\oracle\admin\<your_database_sid>\<your_wallet_directory_name>'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Enter the path of your Oracle Wallet. for example:',
'The entered Wallet Path will overwrite any setup done in the APEX Administration Wallet setup described below:',
'-----------------------------------------------------------------------------------------------------',
'For a more secure setup:',
'-----------------------------------------------------------------------------------------------------',
'Connect to Apex as internal admin user,',
'Goto Home>Manage Instance>Instance Settings',
'set Wallet Path : file:D:\ORACLE\ADMIN\<your_database_sid>\WALLET',
'set Wallet Password: <Wallet Password>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10280313654489437442)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Wallet Password'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'qwer5678'
,p_display_length=>50
,p_is_translatable=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Enter the password of your Oracle Wallet.',
'The entered Wallet Password will overwrite any setup done in the APEX Administration Wallet setup described below:',
'-----------------------------------------------------------------------------------------------------',
'For a more secure setup:',
'-----------------------------------------------------------------------------------------------------',
'Connect to Apex as internal admin user,',
'Goto Home>Manage Instance>Instance Settings',
'set Wallet Path : file:D:\ORACLE\ADMIN\<your_database_sid>\WALLET',
'set Wallet Password: <Wallet Password>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159205766756837621)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'URL reCaptcha Site Verify'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'https://google.com/recaptcha/api/siteverify'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159226454576115314)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Function PL/SQL to get IP address'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'owa_util.get_cgi_env(''REMOTE_ADDR'')'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159233339279328615)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'URL reCaptcha v3 JS'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'https://www.google.com/recaptcha/api.js'
,p_is_translatable=>false
,p_examples=>'https://www.recaptcha.net/recaptcha/api.js'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'https://developers.google.com/recaptcha/docs/faq?hl=pt-br#can-i-use-recaptcha-globally',
'',
'Alternatively you can use https://www.recaptcha.net/recaptcha/api.js'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159177662769087708)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Submit Button Selector'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'button'
,p_is_translatable=>false
,p_examples=>'#BUTTON_ID'
,p_help_text=>'Specify the CSS selector for the button that triggers the submit action. Please set the button action to "Defined by Dynamic Action".'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159179231246093018)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'reCaptcha v3 Score Threshold'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'0.5'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'https://developers.google.com/recaptcha/docs/v3',
'',
'reCAPTCHA v3 returns a score (1.0 is very likely a good interaction, 0.0 is very likely a bot). Based on the score, you can take variable action in the context of your site. Every site is different, but below are some examples of how sites use the sc'
||'ore. As in the examples below, take action behind the scenes instead of blocking traffic to better protect your site.',
'',
'By default, you can use a threshold of 0.5.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159181397036099413)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Error message when the threshold score is not reached'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>unistr('Your request couldn\2019t be verified. Please try again in a moment.')
,p_is_translatable=>false
,p_examples=>unistr('PT-BR: N\00E3o conseguimos confirmar que esta a\00E7\00E3o \00E9 leg\00EDtima. Por favor, tente novamente ou recarregue a p\00E1gina.')
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159239579019599318)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Error Display Location'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'INLINE_IN_NOTIFICATION'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(10159240834826601932)
,p_plugin_attribute_id=>wwv_flow_api.id(10159239579019599318)
,p_display_sequence=>10
,p_display_value=>'Inline with Field and in Notification'
,p_return_value=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(10159241180109603356)
,p_plugin_attribute_id=>wwv_flow_api.id(10159239579019599318)
,p_display_sequence=>20
,p_display_value=>'Inline with Field'
,p_return_value=>'INLINE_WITH_FIELD'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(10159241625099604319)
,p_plugin_attribute_id=>wwv_flow_api.id(10159239579019599318)
,p_display_sequence=>30
,p_display_value=>'Inline in Notification'
,p_return_value=>'INLINE_IN_NOTIFICATION'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(10159242039431605164)
,p_plugin_attribute_id=>wwv_flow_api.id(10159239579019599318)
,p_display_sequence=>40
,p_display_value=>'On Error Page'
,p_return_value=>'ON_ERROR_PAGE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(10159237431481591999)
,p_plugin_id=>wwv_flow_api.id(10280312266942437418)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Language'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'en'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Language Code',
'Arabic - ar',
'Afrikaans - af',
'Amharic - am',
'Armenian - hy',
'Azerbaijani - az',
'Basque - eu',
'Bengali - bn',
'Bulgarian - bg',
'Catalan - ca',
'Chinese (Hong Kong) - zh-HK',
'Chinese (Simplified) - zh-CN',
'Chinese (Traditional) - zh-TW',
'Croatian - hr',
'Czech - cs',
'Danish - da',
'Dutch - nl',
'English (UK) - en-GB',
'English (US) - en',
'Estonian - et',
'Filipino - fil',
'Finnish - fi',
'French - fr',
'French (Canadian) - fr-CA',
'Galician - gl',
'Georgian - ka',
'German - de',
'German (Austria) - de-AT',
'German (Switzerland) - de-CH',
'Greek - el',
'Gujarati - gu',
'Hebrew - iw',
'Hindi - hi',
'Hungarain - hu',
'Icelandic - is',
'Indonesian - id',
'Italian - it',
'Japanese - ja',
'Kannada - kn',
'Korean - ko',
'Laothian - lo',
'Latvian - lv',
'Lithuanian - lt',
'Malay - ms',
'Malayalam - ml',
'Marathi - mr',
'Mongolian - mn',
'Norwegian - no',
'Persian - fa',
'Polish - pl',
'Portuguese - pt',
'Portuguese (Brazil) - pt-BR',
'Portuguese (Portugal) - pt-PT',
'Romanian - ro',
'Russian - ru',
'Serbian - sr',
'Sinhalese - si',
'Slovak - sk',
'Slovenian - sl',
'Spanish - es',
'Spanish (Latin America) - es-419',
'Swahili - sw',
'Swedish - sv',
'Tamil - ta',
'Telugu - te',
'Thai - th',
'Turkish - tr',
'Ukrainian - uk',
'Urdu - ur',
'Vietnamese - vi',
'Zulu - zu'))
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
