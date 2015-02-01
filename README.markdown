# ZWR gem

This gem is a collection of jammed thingies that I want to reuse accross products.

This gem is licensed under MIT license.

# Internationalization and Localization

## I18n helpers in asset pipeline

If you have included this gem, and you are using HAML and any kind of HAML templates
such as angular-rails-templates gem, you can use the following in the template:

    %span=t :'zeljko'
  
This will be (pre)compiled to the default language. I am planning to add some support
for resources that would be precompiled to all existing languages and served in a desired
language, but that would happen later.

## rake loc:extract

This task generates scanns all HAML files (wherever under Rails.root) for all occurances 
of something of the following:

    =t :'zeljko'
    =t :'symbol and fallback' # Default translation

and outputs a following table:

      "zeljko":                   "zeljko"
      "symbol and fallback":      "Default translation"

You should asure this table gets into your localization files.
