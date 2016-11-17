#This is a projects sends automatic email to employees of the company having their birthday.
#The code will wake up, connect to database, check if there is any birthday or not,
#if there is, it will send the email from abc@gmail.com.
#it will then sleep for 1 day. Again wake up and continue..


#Change the HOST at line 27

use strict;
use warnings;

#Modules for email
use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;

#Modules for thread
use threads;
use threads::shared;

#Modules for database conn
use DBI;


#Constants. Dont change them
my $DATABASE_NAME = "perldb";
my $HOST_IP = "192.168.43.45";
my $DATABASE_USER_ID = "anshul";
my $DATABASE_PASSWORD = "anshul";
my $DATABASE_CONNECTION_PATH = "dbi:mysql:database=$DATABASE_NAME;host=$HOST_IP";

my $EMP_TABLE_NAME = "empdetails";
my $EMP_NAME_COL = "EmpName";
my $EMP_EMAIL_COL = "EmpEmail";
my $EMP_BIRTHDAY_COL = "EmpBirthday";

my $DATABASE_ERR_MSG_CANT_CONNECT = "Failed to connect to database.";
my $DATABASE_ERR_MSG_QUERY_ERR = "FAiled to query to database";

my $SLEEP_TIME = 60*60*24;

my $FROM_EMAIL_ID = 'abc@gmail.com';
my $SUBJECT = "Happy Birthday!";
my $MAIL_BODY = "From the company, We wish you a very Happy Birthday!";
my $MAILER = "Gmail";
my $EMAIL_USER_NAME = 'abc@gmail.com';
my $EMAIL_PASSWORD = 'abc';

#main method.
sub main {

	#infinaite for loop, it goes on forever!
	for(;;){
		print "Waking up ...\n";
		print "Connecting to database ...\n";
		my $connection = DBI->connect($DATABASE_CONNECTION_PATH,
			$DATABASE_USER_ID,
			$DATABASE_PASSWORD,
			{AutoCommit=>1,RaiseError=>1,PrintError=>0})
		or die $DATABASE_ERR_MSG_CANT_CONNECT;
		print "Connected to database ...\n";


		#fetch entries from the database
		my $result = $connection->prepare("SELECT * FROM $EMP_TABLE_NAME");

		$result->execute() or die $DATABASE_ERR_MSG_QUERY_ERR;


		(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();

		#line 74 to 84 are for getting the todays date in the format as same as the format of date stored in db (mm/dd/yyyy).

		#add one to day. and append 0 if required.
		$mon = $mon+1;
		if( length($mon) == 1){
			$mon = "0".($mon);
		}

		#append 0 to month if required
		if(length($mday) == 1){
			$mday = "0".($mday);
		}
		my $TODAY = "$mday/$mon/".($year+1900);

		#Iterate through each row
		while (my @row = $result->fetchrow_array()) {
   			my ($empname, $empemail,$empbdate ) = @row;
   			print "Name = $empname, Email = $empemail Birthday : $empbdate\n";

   			#check if the date is today
   			if( $empbdate eq $TODAY ){
   				print "$empname has Birthday today, Sending mail please wait ...\n";

   				#prepare email body.
   				my $email = Email::Simple->create(
      				header => [
          				From    => $FROM_EMAIL_ID,
          				To      => $empemail,
          				Subject => $SUBJECT,
      				],
      				body => $MAIL_BODY,);

  				my $sender = Email::Send->new(
      				{	mailer 	=> $MAILER,
          				mailer_args => [
              				username => $EMAIL_USER_NAME,
              				password => $EMAIL_PASSWORD,
          				]
      				}
  				);
  				eval { $sender->send($email) };
  				die "Error sending email: $@" if $@;

  				print "Email sent to $empemail\n";
   			}

		}

		$result->finish();
		print "Sleeping ...\n";
		sleep($SLEEP_TIME);
	}

}

#threads->create('main')->join();
&main();
