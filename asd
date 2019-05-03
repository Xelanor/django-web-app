<!-- Crew Manifest BR  -->
  <process name="manifest_br"
      dbConn="profile:live"
          dbSchema="%(dave/live/schema)"
          continueOnMessageError="True">

    <start_cmd>digmain -c manifest_br</start_cmd>
    <start_wait_time>0</start_wait_time>
	<ping_interval>20</ping_interval>
	<!--ha_process>false</ha_process-->
    <log_file>${CARMTMP}/logfiles/fcm/br/channel_${HOST}</log_file>
    <log_stdout>true</log_stdout> <!-- Redirects both stderr and stdout to the logfile. -->
    <logs_to_keep>10</logs_to_keep>

<jcmslog>
 	<flow name="." level="INFO">
 		<appender class="FileAppend" maxSizeKb="1000000" filename="${CARMTMP}/logfiles/fcm/br/fcm_${HOST}.log" />
 	</flow>
</jcmslog>

      <reader class="carmensystems.dig.scheduler.job.JobReader"
          onlyLatest="True"/>
      <messagehandlers>
        <messagehandler class="carmusr.interfaces.common.triggers.FlightDepartureTrigger"
            outputClass="carmusr.interfaces.common.triggers.CrewManifestRequestBuilder"
            destCountry="BR"
            depCountry="BR"
            catchMissedFlights="True"
            minutesBefore="-5" />
          <messagehandler class="carmensystems.dig.messagehandlers.reports.ReportRequestHandler" 
              defaultServer="rs_latest"
              rs_latest="%(API/getServiceUrl/portal_latest)"
              contentIsReports="False"/>
          <messagehandler class="carmusr.interfaces.common.xhandlers.APISFallBackHandler"/>
          <messagehandler class="carmensystems.dig.messagehandlers.dave.DaveWriter" 
              cacheSize="0" 
              ignoreOutOfOrder="True"
              ageTimeout="-1" 
              idleTimeout="-1" 
              raiseRetryErrors="False"/>
          <messagehandler class="carmensystems.dig.messagehandlers.reports.ReportContentSwitcher"/>
          <messagehandler class="carmusr.interfaces.common.xhandlers.MailBlocker"
              enabled="%(dig_settings/mail@blocked)"
              recipients="%(dig_settings/mail/test_to)" />
          <messagehandler class="carmusr.interfaces.common.xhandlers.AddressInjector"
              default_dests="mqdest,archive"
              mqdest_protocol="mq"
              mqdest_mq_manager="%(mq/manager)"
              mqdest_mq_queue="%(mq/apis_telex/queue)"
              dest_protocol="file"
              dest_file_filename="%(dig_reports/crew_manifest)/CrewManifest_BR.__MSGCOUNT__.###.__TIMESTAMP__"
              archive_dests="archive"
              archive_protocol="file"
              archive_file_filename="$(CARMDATA)/REPORTS/EXPORT/BR/CrewManifest_BR.__MSGCOUNT__.###.__TIMESTAMP__"/>
          <messagehandler class="carmensystems.dig.messagehandlers.transport.TransportDispatcher"
              mq_host="%(mq/server)"
              mq_port="%(mq/port)"
              mq_channel="%(mq/apis_telex/channel)" 
              file_mkdirs="True"
              mail_host="%(dig_settings/mail/host)"
              mail_port="%(dig_settings/mail/port)"
              mail_defaultTo="smutluer@thy.com"
              mail_defaultFrom="crewapis@thy.com"/>
      </messagehandlers>
      <notifiers>
          <notifier category="message"
              class="carmensystems.dig.notifiers.mail.MailNotifier"
              host="%(mail/host)"
              port="%(mail/port)"
              sender="%(mail/from)"
              recipients="%(mail/to)"
              subject="DIG channel 'manifest_br' message error" />
          <notifier category="fatal"
              class="carmensystems.dig.notifiers.mail.MailNotifier"
              host="%(mail/host)"
              port="%(mail/port)"
              sender="%(mail/from)"
              recipients="%(mail/to)"
              subject="DIG channel 'manifest_br' fatal error" />
      </notifiers>
  </process>
