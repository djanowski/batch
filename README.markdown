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

Debugging
---------

If you want Batch to halt as soon as there's an exception (just like a regular
`each` loop would do), simply set `$DEBUG` to true. If you're running Ruby
explicitly, then:

    $ ruby -d <your-batch-script>

If you're running another tool which uses Batch, then set `RUBYOPT`:

    $ RUBYOPT=-d rake foo

Installation
------------

    $ gem install batch
