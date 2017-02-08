# 591-rent-crawler

##  Service
An easy way to notify you the dorm you desired. 

## API Query 

```
Rscript acquire.R --help
```

Usage: Rscript acquire.R [options]

  --desired_section, --section, -s [ character, ... ]
    desired sections, default by 10 and 11 (i.e. -s 10 -s 11)

  --desired_region, --region, -r integer
    desired sections region, default = 1

  --desired_area_range, --area, -a [ character, ... ]
    area range, 10, 20, 30, 40. default = '10,30'

  --desired_rent, --rent, -r [ character, ... ]
    rent, default='2,3,4', indicating $5k--$30k

  --desired_gender_rest, --gender, -g character
    gender restriction where 0 = none, 1 = male only, 2 = female only, default = 0

  --verbose
    print messages

  --help
    Print help message and exit

  --version
    Print version information and exit

Please contact kaeaura@gmail.com for comments

where desired_section:

    # section 鄉鎮
    # 10: 內湖
    # 4: 松山
    # 11: 南港區
    # 27: 汐止

    #rentpriceMore 租金
    # 2: 5k - 10k
    # 3: 10k - 20k
    # 4: 20k - 30k

    # area 坪數
    # 20,30: 20坪到30坪

    #sex 性別
    # 0: 不限


