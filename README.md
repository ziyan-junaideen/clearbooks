# Clearbooks
Version 0.18.2

[![Gem Version](https://badge.fury.io/rb/clearbooks.svg)](http://badge.fury.io/rb/clearbooks)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://img.shields.io/badge/license-MIT-brightgreen.svg)

This is an unofficial Clear Books [1] API gem to handle any kind of interaction of their SOAP
Service [2] via a native Ruby interface. Clear Books is an online accounting software usable as a
Software as a Service (SaaS). Their official API works via SOAP and WSDL and currently is only officially supported
via PHP [3].

It allows the handling of invoices, expenses, financial accounts and mobile accounting as well as online HR and payroll.


[1] Clear Books PLC, https://www.clearbooks.co.uk

[2] https://www.clearbooks.co.uk/support/api

[3] https://www.clearbooks.co.uk/support/api/code-examples/php/

[4] https://github.com/clearbooks


## Features

- Application
  - Ruby VM (2.2 or better)
- Feature Providing Base Libraries
  - Savon
  - Thor
- Development
- Development Base Libraries
  - RVM
  - Rake
  - Thor
- Code Quality
  - Code review
  - Yard & related  (gem install yard --no-ri --no-rdoc ; gem install rdiscount --no-ri --no-rdoc)
  - MetricFu/RSpec/Cucumber


## Installing

To install the `Clearbooks` gem, run the `gem` command:

```sh
gem install clearbooks
```

Or update your `Gemfile`:

```ruby
gem 'clearbooks', github: 'greylon/clearbooks'
```

## Configuration

To use the Clearbooks API, you need to get an API key on http://clearbooks.co.uk.

Login to the site and choose `Settings` > `API`.

Store the API key and configuration options in `config/clearbooks.yml`, `.clearbooks/config.yml`, or `~/.clearbooks/config.yml`.


```sh
$ echo "api_key: {your_api_key}" >> ~/.clearbooks/config.yml
```

Or provide the API key in `ENV['CLEARBOOKS_API_KEY']`

```sh
$ CLEARBOOKS_API_KEY=your_api_key clearbooks
```

Or use `Clearbooks.configure` block:

```ruby
require 'clearbooks'

Clearbooks.configure do |config|
    config.api_key = 'your_api_key'     # Unless you have key in ~/.clearbooks/config.yml
                                        # or ENV['CLEARBOOKS_API_KEY']
    config.log = true                   # If you need logging
    config.logger = Logger.new(STDOUT)  # Or any other logger of your choice
end
```

## Usage

### Ruby code

```ruby

Clearbooks.list_invoices        # returns Array of existing invoices
Clearbooks.list_entities        # returns Array of existing entities
Clearbooks.list_projects        # returns Array of existing projects
Clearbooks.list_account_codes   # returns Array of available account codes

Clearbooks.create_invoice Clearbooks::Invoice.new(date_created: Date.today,
      credit_terms: 30,
      entity_id: 1,
      type: :purchases,
      items: [
        Item.new(description: 'Item 1', unit_price: '9.99',
            quantity: 5, type: '1001001', vat: 0, vat_rate: '0.00:Out'),
        Item.new(description: 'Item 2', unit_price: '19.99',
            quantity: 7, type: '1001001', vat: 0, vat_rate: '0.00:Out')]
      ])
```
See the API reference below or visit the official Clearbooks site: https://www.clearbooks.co.uk/support/api/docs/soap/

### Command line
Type `clearbooks` or `clearbooks console` in the command line to launch [pry](https://github.com/pry/pry) in context of Clearbooks:
```sh
$ clearbooks
[1] pry(Clearbooks)> list_invoices
# ...
[1] pry(Clearbooks)> create_invoice Invoice.new(params)
# ...
[1] pry(Clearbooks)> exit
```

# Clearbooks API reference

Detailed API reference can be obtained from official Clearbooks site: https://www.clearbooks.co.uk/support/api/docs/soap/

## Managing invoices

### Clearbooks.list_invoices

Example:

```ruby
Clearbooks.list_invoices(
    id:             [1, 2, 3],          # Optional. Filter invoices by invoice id
    entity_id:      [1, 2, 3],          # Optional. Filter invoices by entity id
    ledger:         :sales,             # Optional. One of [:sales, :purchases]
    status:         :all,               # Optional. One of
                                        # [:draft, :voided, :bad_debt, :valid, :paid, :unpaid,
                                        #       :credited, :credit_note, :refund, :recurring]
    modified_since: '2015-01-01',       # Optional.
    offset: 0                          # Optional. It returns 100 invoices a time.
    ) # Clearbooks.list_invoices

 # Returns an Array of Invoice objects with attributes according to official API docs.
```
Reference: https://www.clearbooks.co.uk/support/api/docs/soap/listinvoices/

### Clearbooks.create_invoice

Example:

```ruby
Clearbooks.create_invoice Clearbooks::Invoice.new(
    date_created:   Date.today, # Reqiured. The tax point of the invoice.
    date_due:       Date.today, # The date the invoice is due.
    credit_terms:   30,         # The number of days after the tax point that the invoice is due.
                                # Either :date_due or :credit_terms is required.
    entity_id:      1,          # Required. The customer or supplier id.
    date_accrual:   Date.today, # Optional. The invoice accrual date.
    description:    'desc'      # Optional.
    type:           :purchases, # Optional. One of [:purchases, :sales, :cn-sales, :cn-purchases]
    bank_payment_id: 200,       # Optional. The bank account code.
        # Can be extracted from the bank account URL:
        # 1. Go to Clearbooks site > Money > Bank accounts > All
        # 2. Click the bank account.
        # 3. In the address bar you will see the url like:
        #   https://secure.clearbooks.co.uk/company/accounting/banking/statement/7502001/
        # 4. The last number (7502001) is the bank account code.

    items: [
        Item.new(
            description: 'Item 1',  # Reqiured.
            unit_price: '9.99',     # Required.
            quantity: 5,            # Required.
            type: '1001001',        # Required. The item account code.
                                    # Use Clearbooks.list_account_codes
                                    # to get available account codes.
            vat: 0,                 # Reqiured.
            vat_rate: '0.00:Out'    # Required.
            )] # items
) # Clearbooks.create_invoice

# returns a Hash:

    {
        invoice_id: 1,
        invoice_prefix: 'INV',
        invoice_number: '1'
    }
```
Reference: https://www.clearbooks.co.uk/support/api/docs/soap/createinvoice/

### Clearbooks.void_invoice

Example:

```ruby
Clearbooks.void_invoice(
    'purchases',    # 'purchases' or 'sales'
    10              # Invoice id
) # Clearbooks.void_invoice

# returns a Hash:

    {
        :@success   => true,
        :@msg       => 'Some status message'
    }
```

## Managing entities
### Clearbooks.list_entities

Example:

```ruby
Clearbooks.list_entities(
    id: [1, 2, 3],                  # Optional. Filter entities by id.
    type: :customers,               # Optional. One of [:customers, :suppliers]
    modified_since: '2015-01-01',   # Optional.
    offset: 0                       # Optional.
) # Clearbooks.list_entities

# returns an Array of Entity objects with attributes according to official API docs.
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/list-entities/

### Clearbooks.create_entity

Example:

```ruby
Clearbooks.create_entity Clearbooks::Entity.new(
    company_name: 'Company',
    contact_name: 'John Doe',
    supplier: {
       default_account_code: '1001001', # See Clearbooks.list_account_codes
       default_credit_terms: 30,
       default_vat_rate: 0
   }
) # Clearbooks::Entity.new
```
Full list of options: https://www.clearbooks.co.uk/support/api/docs/soap/createentity/

### Clearbooks.update_entity

Example:

```ruby
Clearbooks.update_entity Clearbooks::Entity.new(
    id: 10,
    company_name: 'Company',
    contact_name: 'John Doe',
    supplier: {
       default_account_code: '1001001', # See Clearbooks.list_account_codes
       default_credit_terms: 30,
       default_vat_rate: 0
   }
) # Clearbooks::Entity.new
```
Full list of options: https://www.clearbooks.co.uk/support/api/docs/soap/createentity/

### Clearbooks.delete_entity

Example:
```ruby
    Clearbooks.delete_entity(1) # Delete entity by id.
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/deleteentity/


## Managing payments
### Clearbooks.create_payment

Example:

```ruby
Clearbooks.create_payment Payment.new(
    accounting_date: Date.today,    # Optional
    type: :sales,                   # Optional. One of [:purchases, :sales]
    description: 'description',     # Optional.
    amount: 19.99,                  # Optional.
    entity_id: 1,                   # Optional.
    payment_method: 2,              # Optional.
    bank_account: 200,              # Optional. See Clearbooks.create_invoice
    invoices: [                     # Optional.
        {id: 1, amount: 9.99}
    ] # invoices
) # Payment.new
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/createpayment/

### Clearbooks.allocate_payment

Example:
```ruby
Clearbooks.allocate_payment(
    payment_id:   1,        # Reqiured.
    entity_id:    1,        # Required.
    type:         :sales,   # Required. One of [:sales, :purchases]
    invoices:     [
        {id: 1, amount: 9.99}
    ]
) # Clearbooks.allocate_payment
```
Reference: https://www.clearbooks.co.uk/support/api/docs/soap/allocatepayment/

## Managing projects
### Clearbooks.list_projects

Example:

```ruby
Clearbooks.list_projects { offset: 0 }
# returns an Array of Project objects with attributes according to official API docs.
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/listprojects/

### Clearbooks.create_project

Example:
```ruby
Clearbooks.create_project Project.new(
    description: 'Description',     # Required.
    project_name: 'Project name',   # Optional.
    status: :open                   # Optional. One of [:open, :closed, :deleted]
) # Clearbooks.create_project
```
Reference: https://www.clearbooks.co.uk/support/api/docs/soap/createproject/


## Managing journals
### Clearbooks.create_journal

Example:

```ruby
Clearbooks.create_journal Journal.new(
    description: 'Desc',            # Required.
    accounting_date: Date.today,    # Optional.
    entity: 1,                      # Optional.
    project: 1,                     # Optional
    ledgers: [                      # Optional
        {
            account: '1001001',     # Optional. See Clearbooks.list_account_codes
            amount:  19.99,         # Optional.
    ] # ledgers
) # Journal.new
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/createjournal/

### Clearbooks.delete_journal

Example:
```ruby
    Clearbooks.delete_journal(1) # Delete journal by id
```
Reference: https://www.clearbooks.co.uk/support/api/docs/soap/deletejournal/

## Managing account codes
### Clearbooks.list_account_codes

Example:

```ruby
Clearbooks.list_account_codes
# returns an Array of AccountCode objects with attributes according to official API docs.
```

Reference: https://www.clearbooks.co.uk/support/api/docs/soap/listaccountcodes/

## On what Hardware does it run?

This Software was originally developed and tested on 32-bit x86 / SMP based PCs running on
Gentoo GNU/Linux 3.13.x. Other direct Linux and Unix derivates should be viable too as
long as all dynamical linking dependencys are met.


## Documentation

A general developers API guide can be extracted from the Yardoc subdirectory which is able to
generate HTML as well as PDF docs. Please refer to the [Rake|Make]file for additional information
how to generate this documentation.

```sh
~# rake docs:generate
```

## Software Requirements

This package was developed and compiled under Gentoo GNU/Linux 3.x with the Ruby 2.x.x.
interpreter. It uses several libraries and apps as outlied in the INSTALLING section.

 - e.g. Debian/GNU Linux or Cygwin for MS Windows
 - Ruby
 - RVM or Rbenv
 - Bundler

## Configuration

Configuration is handled at run-time via $HOME/.clearbooks/config.yaml file.

## Build & Packaging

Package building such as RPM or DEB has not been integrated at this time.

To build the gem from this repository:


```sh
~# rake build
~# rake package
~# rake install
```

## Development

#### Software requirements

This package was developed and compiled under Gentoo GNU/Linux 3.x with the Ruby 2.x.x.
interpreter.

#### Setup

If you got this package as a packed tar.gz or tar.bz2 please unpack the contents in an appropriate
folder e.g. ~/clearbooks/ and follow the supplied INSTALL or README documentation. Please delete or
replace existing versions before unpacking/installing new ones.

Get a copy of current source from SCM

```sh
~# git clone ssh://github.com/greylon/clearbooks.git clearbooks
```

Install RVM (may not apply)

```sh
~# curl -sSL https://get.rvm.io | bash -s stable
```

Make sure to follow install instructions and also integrate it also into your shell. e.g. for ZSH,
add this line to your .zshrc.

```sh
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" ;

or

~# echo "source /usr/local/rvm/scripts/rvm" >> ~/.zshrc

```

or see `http://rvm.io` for more details.


Create proper RVM gemset

```sh
~# rvm --create use 2.2.2@clearbooks_project
```

Install Ruby VM 2.2.2 or better

```sh
~# rvm install 2.2.2
```

Install libraries via bundler

```sh
~# gem install bundler
~# bundle
```

#### Rake Tasks

For a full list of Rake tasks suported, use `rake -T`.

Here is a current listing of all tasks:


```
rake build                  # Build clearbooks-0.18.2.gem into the pkg directory
rake cucumber:pretty        # Run Cucumber features
rake cucumber:progress      # Run Cucumber features
rake default                # Show the default task when executing rake without arguments
rake docs:generate          # Generate Yardoc documentation for this project
rake docs:graph             # Generate Yard Graphs for this project
rake guard:default          # Execute Ruby Guard
rake help                   # Shows the usage help screen
rake install                # Build and install clearbooks-0.18.2.gem into system gems
rake install:local          # Build and install clearbooks-0.18.2.gem into system gems without network access
rake man:build              # Build the manual pages
rake man:clean              # Clean up from the built man pages
rake measurement:benchmark  # When executing rake tasks measure elapsed time, used with other tasks
rake measurement:profiling  # Run profiling over stack
rake metric:metric          # Run metric fu for project
rake package:clean          # Clean all files from pkg folder
rake readme                 # Generate proper README file from templates
rake readme:all             # Generate proper README file from templates
rake readme:subdirs         # Builds generates readme files in all sub-directories
rake readme:topdir          # Generate top level README file from template
rake release                # Create tag v0.18.2 and build and push clearbooks-0.18.2.gem to Rubygems
rake spec                   # RSpec Core Tasks
rake todo                   # Look for TODO and FIXME tags in the code
rake version                # Git Tag number of this repo
rake yardgraph              # Generate Yard Graphs for this project
rake yardoc                 # Generate Yardoc documentation for this project

```

#### Thor Tasks

For a full list of Thor tasks suported, use `thor -T`.

Here is a current listing of all tasks:


```
default
-------
thor :build                  # build
thor :clean                  # clean
thor :default                # Show the default task when executing rake without arguments
thor :docs:generate          # Generate Yardoc documentation for this project
thor :docs:graph             # Generate Yard Graphs for this project
thor :guard:default          # Execute Ruby Guard
thor :help                   # Shows the usage help screen
thor :install                # Build and install clearbooks-0.18.2 .gem into system gems
thor :man:build              # Build the manual pages
thor :man:clean              # Clean up from the built man pages
thor :measurement:benchmark  # When executing rake tasks measure elapsed time, used with other tasks
thor :measurement:profiling  # Run profiling over stack
thor :metric:metric          # Run metric fu for project
thor :package:clean          # Clean all files from pkg folder
thor :readme:all             # Generate proper README file from templates
thor :readme:subdirs         # Builds generates readme files in all sub-directories
thor :readme:topdir          # Generate top level README file from template
thor :release                # release
thor :spec                   # Run RSpec code examples
thor :todo                   # Look for TODO and FIXME tags in the code
thor :version                # Git Tag number of this repo

info
----
thor info:overview  # Shows system overview

version
-------
thor version:show  # Show version of this app


```

## If something goes wrong

In case you enconter bugs which seem to be related to the package please check in
the MAINTAINERS.md file for the associated person in charge and contact him or her directly. If
there is no valid address then try to mail Bjoern Rennhak <bjoern AT greylon DOT com> to get
some basic assistance in finding the right person in charge of this section of the project.

## Contributing

1. Fork it ( https://github.com/greylon/clearbooks/fork )
2. Create your feature branch (`git checkout -b my_new_feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my_new_feature`)
5. Create a new Pull Request

## Authors

* [Oleg Kukareka](https://github.com/kukareka)
* [Bjoern Rennhak](https://github.com/rennhak)

## Copyright & License

Please refer to the COPYING.md and LICENSE.md file.
Unless otherwise stated in those files all remains protected and copyrighted by Bjoern Rennhak
(bjoern AT greylon DOT com).

