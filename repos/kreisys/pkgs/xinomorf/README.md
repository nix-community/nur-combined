# Xinomorf

![Xinomorf](misc/xinomorf.png)

## Wait What?

Terraform is awesome!

It lets us implement our infrastructure as code across many providers AND helps us collaborate with our team members using remote state.

More than once have I been pulling my hair over seemingly random limitations of the [HCL](https://github.com/hashicorp/hcl)-based language Terraform uses for its configuration. To name a few off the top of my head:
- Not being able to use a variable in a module source
- Modules can't be multiplied/repeated with `count`s
- No easy way to work with temporary local files (aws lambda anyone?)

Really no shade intended though! I'm absolutely sure those things are being addressed as I'm typing these lines.
Hashicorp are a super smart and competent bunch and I can't even imagine where I would've been today without them (hint: drowning in Chef rb files)

Nix on the other hand is absolutely a pleasure to work with for templating (pretty sure it was designed with that in mind). Fetching stuff from all over the place is a breeze, creating ad-hoc files is straight-forward and no need to worry about temporary file names or locations (yay `/nix/store`!). So why not use Nix to generate Terraform configs?

## How?

Xinomorf doesn't actually do much. Srsly!
Basically we take `*.tf.nix` files and turn them into `*.tf` files.

### Firstly,

`.tf` files are just passed through as they are. That's useful for painless incremental migration. Instead of having to convert everything at once, we can convert one file at a time and some never at all. Let's start with a `hello world` example; starting with a POTF (Plain Old Terraform File):

```terraform
# hello.tf
resource "null_resource" "hello" {
  # Just so that this never gets skipped. For the lulz!
  triggers {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "echo hello world"
  }
}
```

### Makes sense, got it. What about them `tf.nix` files?

`tf.nix` files are simply files containing a nix expression; those expressions are expected to define a function, which takes an attribute set. That attribute set consists of stub functions corresponding to Terraform keywords such as `resource`, `data`, `variable`, `provisioner` etc. Those functions do nothing fancy; they basically just return a string consisting of their own name and a stringification of their arguments, as would appear in a `.tf` file. Hence:

```nix
# hello.tf.nix
{ resource, provisioner, ... }:
## ... or we could do:
# stubs: with stubs;
## if we wanna be lazy douchebags...

[
  (resource "null_resource" "hello" {
    triggers = {
      uuid = "\${uuid()}";
    };
  } [
    (provisioner "local-exec" {
      command = "echo hello world";
    })
  ])
]
```

is equivalent to `hello.tf` above! Two things should be noted here:

1. The `resource` function takes a *resource type* and a *resource name*; then, it takes an attrset (kinda like Terraform) and then, unlike Terraform, a list. That is in order to be able to express the **repeatable** `provisioner` stanza in Nix (as opposed to the "singleton" `triggers` stanza).
2. We have to escape `\${uuid}` so that we can access Terraform's `uuid()` interpolation (otherwise it would've been interpreted as a Nix expression and fail due to `uuid` not being defined or `uuid()` being invalid Nix syntax or idk but it would fail.)

Cool! Now we can generalize. Kinda like a Terraform module, but the Xinomorf way!
Let's say we want to internationalize our hello world example:

```nix
# lib/make-hello.nix
{ resource, provisioner, ... }:

lang: greeting:
## ... or we could *still* do:
# stubs: with stubs;
## ... but only if we wanna be lazy f**kt**ds...

[
  (resource "null_resource" "${lang}-greet" {
    triggers = {
      uuid = "\${uuid()}";
    };
  } [
    (provisioner "local-exec" {
      command = "echo ${greeting}";
    })
  ])
]
```

And now our `hello.tf` can be so much shorter and do so much moar! (and it would look like this):
```nix
# Now it's fine because we don't care what's in there; we just pass it along!
stubs:

let mkHello = import ./lib/make-hello.nix { inherit stubs; }; in
[
  (mkHello "en" "hello world")
  (mkHello "de" "hallo welt")
  (mkHello "fr" "bonjour tout le monde")
  # .. etc
]
```

Now, considering the fact that `mkHello` can encapsulate an arbitrarily complex Terraform (... or Nix... or both) configuration, this is pretty cool!


### Wait let's rewind for a sec...

SO BTW, from the get go we could have just done:

```nix
{ ... }:

[
  ''
  resource "null_resource" "hello" {
    triggers {
      uuid = "''${uuid}"
    }

    provisioner "local-exec" {
      command = "echo hello world"
    }
  }
  ''
]
```

(Note the '' escape in the `uuid = "''${uuid}"` declaration! We are using a Nix multiline string here so we escape differnetly. However, we must still escape in order to get the Terraform interpolation.)
This is strikingly easier and arguably even prettier; so what's the point? Maybe there isn't any. This whole thing is an experiment. Also, truth be told, I have not written any stubs for any nested keywords other than `provisioner` for this example. The whole point of it is to implement functions that produce Terraform infrastructure. The stubs are just the most basic functions possible. It might be feasible to use the argument list to pass around more complex functions as well.

## Want!

### Prerequisites

- Nix

That's it.

### Install

```
$ git clone https://github.com/kreisys/xinomorf
$ cd xinomorf
$ nix-env -f. -iA cli
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
