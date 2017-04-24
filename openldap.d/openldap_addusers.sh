#!/usr/bin/bash

# Wait for the ldap server to be up and running
sleep 15

# Create entries for dummy users on the ldap server
echo "Configuring demo users on LDAP server..."
for i in {0..9};
do
	# Make a ldif file for each user
	echo "dn: uid=user$i,dc=example,dc=org
	objectclass: top
	objectclass: account
	objectclass: posixAccount
	objectclass: shadowAccount
	cn: user$i
	uid: user$i
	uidNumber: 100$i
	gidNumber: 100$i
	homeDirectory: /home/user$i
	loginShell: /bin/bash
	gecos: user$i
	userPassword: {crypt}x
	shadowLastChange: 0
	shadowMax: 0
	shadowWarning: 0" > newuser.ldif
	# Add the user and set a password for her
	ldapadd -x -H ldap://ldap -D "cn=admin,dc=example,dc=org" -w admin -f newuser.ldif
	ldappasswd -x -H ldap://ldap -D "cn=admin,dc=example,dc=org" -w admin "uid=user$i,dc=example,dc=org" -s test$i
done

# Also add a dummy administrator
echo "dn: uid=dummy_admin,dc=example,dc=org
objectclass: top
objectclass: account
objectclass: posixAccount
objectclass: shadowAccount
cn: dummy_admin
uid: dummy_admin
uidNumber: 1010
gidNumber: 1010
homeDirectory: /home/dummy_admin
loginShell: /bin/bash
gecos: dummy_admin
userPassword: {crypt}x
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0" > dummy_admin.ldif
ldapadd -x -H ldap://ldap -D "cn=admin,dc=example,dc=org" -w admin -f dummy_admin.ldif 
ldappasswd -x -H ldap://ldap -D "cn=admin,dc=example,dc=org" -w admin "uid=dummy_admin,dc=example,dc=org" -s adminadmin

# Clean up
rm newuser.ldif
rm dummy_admin.ldif

# Removing the lock for EOS-Storage
echo "Unlocking eos-controller for EOS-Storage deployment."
rm /tmp/SWAN-in-Docker/eos-storage-lock
echo "I'm done. Exiting..."