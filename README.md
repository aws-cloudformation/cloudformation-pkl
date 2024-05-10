# cloudformation-pkl

Pkl is a configuration language created by Apple (https://pkl-lang.org/index.html). 
It is capable of serializing to other formats like YAML, so it's possible to
write a CloudFormation template with pkl. This repository hosts the `cloudformation.pkl`
package that can be imported into your projects to provide a type-safe authoring experience.
The package also has a set of high level patterns that you adapt for your own needs.

The following is a basic example of a pkl CloudFormation template.

```pkl
AWSTemplateFormatVersion: String = "2010-09-09"
Description = "My template"
Parameters {
    ["Name"] {
        ["Type"] = "String"
    }
}
Resources {
    ["MyBucket"] {
        ["Type"] = "AWS::S3::Bucket"
        ["Properties"] {
            ["BucketName"] {
                ["Ref"] = "Name"
            }
        }
    }
}
```

Running `pkl eval -f yaml` on this file results in the following:

```yaml
AWSTemplateFormatVersion: 2010-09-09
Description: My template
Parameters:
  Name:
    Type: String
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName:
        Ref: Name
```

Here's an example of a file you could write using modules in the `cloudformation.pkl` package:

```pkl
amends "@cfn/template.pkl"
import "@cfn/cloudformation.pkl" as cfn
import "@cfn/aws/s3/bucket.pkl" as bucket

Description = "Create a bucket"

Metadata { 
    ["Foo"] = "bar"
}

Parameters {
    ["Name"] {
        Type = "String"
        Default = "baz"
    }
}

Resources {
    ["TypedBucket"] = new bucket.Bucket {
        BucketName = cfn.Ref("Name")
    }
}
```

Note that the package alias `@cfn` is enabled by creating a `PklProject` file that looks like this:

```pkl
amends "pkl:Project"

dependencies {
    ["cfn"] {
        uri = "package://github.com/aws-cloudformation/cloudformation-pkl/releases/download/cloudformation@0.1.1/cloudformation@0.1.1
    }
}
```

It's possible to build higher level patterns in Pkl. In the following example,
we are building a VPC defined in `patterns/vpc.pkl`.

```pkl
amends "@cfn/template.pkl"
import "@cfn/cloudformation.pkl" as cfn
import "@cfn/patterns/vpc.pkl"

local pub1 = new vpc.Subnet {
    LogicalId = "Pub1"
    IsPublic = true
    Az = cfn.Select(0, cfn.GetAZs("us-east-1")) 
    Cidr = "10.0.0.0/18"
}

local pub2 = new vpc.Subnet {
    LogicalId = "Pub2"
    IsPublic = true
    Az = cfn.Select(1, cfn.GetAZs("us-east-1")) 
    Cidr = "10.0.64.0/18"
}

local priv1 = new vpc.Subnet {
    LogicalId = "Priv1"
    IsPublic = false
    Az = cfn.Select(0, cfn.GetAZs("us-east-1")) 
    Cidr = "10.0.128.0/18"
    PublicNATGateway = pub1.natGateway
}

local priv2 = new vpc.Subnet {
    LogicalId = "Priv2"
    IsPublic = false
    Az = cfn.Select(1, cfn.GetAZs("us-east-1")) 
    Cidr = "10.0.192.0/18"
    PublicNATGateway = pub2.natGateway
}

local myvpc = new vpc {
    LogicalId = "MyVPC"
    Subnets {
        pub1
        priv1
        pub2
        priv2
    }
}

Resources {
    // Create the VPC
    ...myvpc.Resources

    // Create other resources inside the VPC...
}

Outputs {
    ...myvpc.Outputs
}

```

