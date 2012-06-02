Batch
=====

Keep your batch jobs under control.

Description
-----------

Say you have a thousand images to process. You write a script, fire it and go
to bed, only to realize the morning after that an exception was raised and the
script was aborted. Well, no more frustration: now you can use Batch to make
sure your script continues working despite those exceptions, and you can now
get a nice report to read while you drink your morning coffee.

Usage
-----

    require "batch"

    Batch.each(Model.all) do |model|
      # do something with model
      # and see the overall progress
    end

Given that `Model.all` responds to `each` and `size`, you'll get a nice
progress report:

      0% ...........................................................................
     25% ...........................................................................
     50% ...........................................................................
     75% ...........................................................................
    100%

If errors occur, they are handled so that your long-running scripts
don't get interrupted right after you go to bed:

      0% .......E...................................................................
     25% ..........................................E................................
     50% ....................E......................................................
     75% ...........................................................................
    100%

    Some errors occured:

    # ... detailed exceptions here

You can determine the line width by setting the environment variable
`BATCH_WIDTH`, which defaults to 75.

Logging
-------

You may specify `:log` in the options for `#each`:

    Batch.each(Model.all, :log => File.open('foo.log', 'w')) do { |model|
      # do something with model
    }

Or you may specify default options using `Batch.options`:

    Batch.options[:log] = File.open('foo.log', 'w')

    Batch.each(Model.all) do { |model|
      # do something with model
    }

This will put all errors into the given log file, and periodically update
it with the status.

Showing status
--------------

Press Ctrl+C to show the status.

    0%  ...........................................................................
    15% ............E.........................E...................^C
    
         11% done (58 of 500)
         Elapsed:   0 seconds
         Remaining: 4 seconds
         Errors:    2
         Press Ctrl+C again to abort.
    
        ...........................................................................
    30% ..........E......E.........................................................

You can disable this behavior with:

    Batch.options[:status_on_interrupt] = false

Installation
------------

    $ gem install batch

License
-------

Copyright (c) 2010 Damian Janowski and Michel Martens

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
