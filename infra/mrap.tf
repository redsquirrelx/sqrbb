module "bucket_staticweb" {
    for_each = local.bucket_staticweb_regions

    source = "./modules/s3bucket"
    bucket_name = "redsqx-${each.key}-staticweb"
    region = each.key

    enable_access_logs = true
    bucket_access_logs_bucket = module.bucket_access_logs[each.key].bucket
    replicate = false
    enable_event_notifs = false
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