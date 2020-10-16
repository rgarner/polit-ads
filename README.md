# Decoding Trump/Biden 2020

This is the source to [decoder.whotargets.me](https://decoder.whotargets.me).

## Purpose

This project decodes the ad code values that the Trump presidential campaign Facebook adverts use
in order to provide a picture of the motivations and the running of the Trump online ad campaign.

The Trump campaign has 23 [ad codes](https://decoder.whotargets.me/campaigns/trump/ad_codes),
    `utm0` through to `utm22`.

The Biden campaign has 14 [ad codes](https://decoder.whotargets.me/campaigns/biden/ad_codes),
    `utm0` through to `utm13`.

## How to contribute

You can contribute your own decodings – either new ones or edits to existing values – of any ad code
value you like. Their source is in markdown form with some metadata at the start, and can be found at

- [doc/ad_code_values/biden](doc/ad_code_values/biden)
- [doc/ad_code_values/trump](doc/ad_code_values/trump)

### Editing a file

For example, for the Trump `utm3` (Page) value `bv4t`, we determined that it meant
"Black Voices for Trump". The markdown for our definition looks like this:

```
---
value: bv4t
name: Black Voices For Trump
confidence: high
published: 2020-09-01
---

## Why do we think that?

All of the ads come from the
[Black Voices For Trump Facebook page](https://www.facebook.com/BlackVoicesForTrump20)
```

You can edit this [markdown](doc/ad_code_values/trump/3/bv4t.md) directly here on GitHub
and propose your own changes. You can see how that ends up displaying on the site:

- [Black Voices for Trump](https://decoder.whotargets.me/campaigns/trump/ad_codes/3/values/bv4t)

### Proposing a new file

Let's say you decoded one of Trump's [audiences](https://decoder.whotargets.me/campaigns/trump/ad_codes/7)
at `utm7` – perhaps by looking at the ads shown to `audience0235`.

You'd add a markdown file called `audience0235.md` to the [doc/ad_code_values/trump/7](doc/ad_code_values/trump/7)
folder to get a file called `doc/ad_code_values/trump/7/audience0235.md`. It might look something like this:

```
---
value: audience0235
name: Working mothers
confidence: low
published: 2020-09-01
---

## Why do we think that?

All of the ads shown to this audience appear to reference topics of concern to working mothers.
```

Please feel free to get in touch on Twitter via either [@whotargetsme](https://twitter.com/whotargetsme) or
[@rgarner](https://twitter.com/rgarner) for any extra help or advice you might need.

## Credits

– Tags for "decode an ad" persuasion identification – [Illuminating project](https://illuminating.ischool.syr.edu/campaign_2020/), Syracuse

### Contributors to ad code values

With many thanks:

– [Aidan T. Hughes](mailto:aidan.t.hughes@kcl.ac.uk), Kings College London
