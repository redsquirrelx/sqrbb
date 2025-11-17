locals {
    regions = {
        us-east-2 = {}
        eu-west-1 = {}
    }
}

module "bucket_staticweb" {
    for_each = local.regions

    source = "./modules/s3bucket"
    bucket_name = "redsqx-${each.key}-staticweb"
    region = each.key
}

resource "aws_s3control_multi_region_access_point" "staticpage" {
    details {
        name = "redsqx-mrap-web-dist"

        dynamic "region" {
            for_each = module.bucket_staticweb
            content {
                bucket = region.value.bucket
            }
        }
    }
}