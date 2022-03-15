# Journalr

## Architecture

### Accounts

`User` defines a user that can access the system

### Journals

The default journal is the users' "My Journal" which is a generic journal. Users can create additional journals, with some sort of mechanism to decide what the default is (either always My Journal, last journal, or configurable).

`Journal` a collection of pages, can be public or private

`Page` a single page in a journal
