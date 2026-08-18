# Currencies

List of currencies Yahoo Finance supports.

## Usage

``` r
get_currencies()
```

## Value

Symbol, short and long name of the currencies.

## Examples

``` r
# \donttest{
get_currencies()
#>     short_name                           long_name symbol
#> 1          FJD                       Fijian Dollar    FJD
#> 2          MXN                        Mexican Peso    MXN
#> 3          SCR                   Seychellois Rupee    SCR
#> 4          CDF                     Congolese Franc    CDF
#> 5          BBD                    Barbadian Dollar    BBD
#> 6          GTQ                  Guatemalan Quetzal    GTQ
#> 7          CLP                        Chilean Peso    CLP
#> 8          HNL                    Honduran Lempira    HNL
#> 9          UGX                    Ugandan Shilling    UGX
#> 10         ZAR                  South African Rand    ZAR
#> 11         MXV             Mexican Investment Unit    MXV
#> 12         TND                      Tunisian Dinar    TND
#> 13         STN         São Tomé and Príncipe Dobra    STN
#> 14         SLE                Sierra Leonean Leone    SLE
#> 15         SLL                Sierra Leonean Leone    SLL
#> 16         BSD                     Bahamian Dollar    BSD
#> 17         SDG                      Sudanese Pound    SDG
#> 18         IQD                         Iraqi Dinar    IQD
#> 19         CUP                          Cuban Peso    CUP
#> 20         GMD                      Gambian Dalasi    GMD
#> 21         TWD                   New Taiwan Dollar    TWD
#> 22         RSD                       Serbian Dinar    RSD
#> 23         DOP                      Dominican Peso    DOP
#> 24         KMF                      Comorian Franc    KMF
#> 25         MYR                   Malaysian Ringgit    MYR
#> 26         FKP              Falkland Islands Pound    FKP
#> 27         XOF                     CFA Franc BCEAO    XOF
#> 28         GEL                       Georgian Lari    GEL
#> 29         UYU                      Uruguayan Peso    UYU
#> 30         MAD                     Moroccan Dirham    MAD
#> 31         CVE                 Cape Verdean Escudo    CVE
#> 32         TOP                      Tongan Paʻanga    TOP
#> 33         PGK              Papua New Guinean Kina    PGK
#> 34         OMR                          Omani Rial    OMR
#> 35         AZN                    Azerbaijan Manat    AZN
#> 36         KES                     Kenyan Shilling    KES
#> 37         SEK                       Swedish Krona    SEK
#> 38         UAH                   Ukrainian Hryvnia    UAH
#> 39         BTN                  Bhutanese Ngultrum    BTN
#> 40         GNF                       Guinean Franc    GNF
#> 41         MZN                  Mozambican Metical    MZN
#> 42         ERN                      Eritrean Nakfa    ERN
#> 43         SVC                    Salvadoran Colón    SVC
#> 44         ARS                      Argentine Peso    ARS
#> 45         QAR                         Qatari Rial    QAR
#> 46         IRR                        Iranian Rial    IRR
#> 47         XPF                           CFP Franc    XPF
#> 48         THB                           Thai Baht    THB
#> 49         UZS                      Uzbekistan Som    UZS
#> 50         CNY                        Chinese Yuan    CNY
#> 51         MRU                 Mauritanian Ouguiya    MRU
#> 52         BDT                    Bangladeshi Taka    BDT
#> 53         LYD                        Libyan Dinar    LYD
#> 54         BMD                     Bermudan Dollar    BMD
#> 55         KWD                       Kuwaiti Dinar    KWD
#> 56         PHP                     Philippine Peso    PHP
#> 57         RUB                       Russian Ruble    RUB
#> 58         PYG                  Paraguayan Guarani    PYG
#> 59         ISK                     Icelandic Króna    ISK
#> 60         JMD                     Jamaican Dollar    JMD
#> 61         COP                      Colombian Peso    COP
#> 62         USD                           US Dollar    USD
#> 63         MKD                    Macedonian Denar    MKD
#> 64         DZD                      Algerian Dinar    DZD
#> 65         PAB                   Panamanian Balboa    PAB
#> 66         SGD                    Singapore Dollar    SGD
#> 67         ETB                      Ethiopian Birr    ETB
#> 68         KGS                      Kyrgystani Som    KGS
#> 69         VUV                        Vanuatu Vatu    VUV
#> 70         SOS                     Somali Shilling    SOS
#> 71         LAK                             Lao Kip    LAK
#> 72         BND                       Brunei Dollar    BND
#> 73         XAF                      CFA Franc BEAC    XAF
#> 74         LRD                     Liberian Dollar    LRD
#> 75         CHF                         Swiss Franc    CHF
#> 76         HRK                                Kuna    HRK
#> 77         DJF                    Djiboutian Franc    DJF
#> 78         ALL                        Albanian Lek    ALL
#> 79         VES         Venezuelan Bolívar Soberano    VES
#> 80         ZMW                                 ZMW    ZMW
#> 81         TZS                  Tanzanian Shilling    TZS
#> 82         VND                     Vietnamese Dong    VND
#> 83         AUD                   Australian Dollar    AUD
#> 84         ILS                  Israeli New Sheqel    ILS
#> 85         GYD                    Guyanaese Dollar    GYD
#> 86         KPW                    North Korean Won    KPW
#> 87         GHS                       Ghanaian Cedi    GHS
#> 88         KHR                      Cambodian Riel    KHR
#> 89         BOB                  Bolivian Boliviano    BOB
#> 90         MDL                        Moldovan Leu    MDL
#> 91         IDR                   Indonesian Rupiah    IDR
#> 92         KYD               Cayman Islands Dollar    KYD
#> 93         AMD                       Armenian Dram    AMD
#> 94         TRY                        Turkish Lira    TRY
#> 95         SHP                  Saint Helena Pound    SHP
#> 96         BWP                      Botswanan Pula    BWP
#> 97         LBP                      Lebanese Pound    LBP
#> 98         TJS                  Tajikistani Somoni    TJS
#> 99         JOD                     Jordanian Dinar    JOD
#> 100        HKD                    Hong Kong Dollar    HKD
#> 101        AED         United Arab Emirates Dirham    AED
#> 102        RWF                       Rwandan Franc    RWF
#> 103        EUR                                Euro    EUR
#> 104        LSL                        Lesotho Loti    LSL
#> 105        DKK                        Danish Krone    DKK
#> 106        CAD                     Canadian Dollar    CAD
#> 107        BGN                       Bulgarian Lev    BGN
#> 108        MMK                         Myanma Kyat    MMK
#> 109        SYP                        Syrian Pound    SYP
#> 110        NOK                     Norwegian Krone    NOK
#> 111        MUR                     Mauritian Rupee    MUR
#> 112        GIP                     Gibraltar Pound    GIP
#> 113        RON                        Romanian Leu    RON
#> 114        LKR                    Sri Lankan Rupee    LKR
#> 115        NGN                      Nigerian Naira    NGN
#> 116        CRC                   Costa Rican Colón    CRC
#> 117        CZK               Czech Republic Koruna    CZK
#> 118        PKR                     Pakistani Rupee    PKR
#> 119        XCD               East Caribbean Dollar    XCD
#> 120        HTG                      Haitian Gourde    HTG
#> 121        ANG       Netherlands Antillean Guilder    ANG
#> 122        XCG                   Caribbean Guilder    XCG
#> 123        BHD                      Bahraini Dinar    BHD
#> 124        SRD                   Surinamese Dollar    SRD
#> 125        KZT                   Kazakhstani Tenge    KZT
#> 126        SZL                     Swazi Lilangeni    SZL
#> 127        TTD          Trinidad and Tobago Dollar    TTD
#> 128        SAR                         Saudi Riyal    SAR
#> 129        YER                         Yemeni Rial    YER
#> 130        MVR                   Maldivian Rufiyaa    MVR
#> 131        AFN                      Afghan Afghani    AFN
#> 132        INR                        Indian Rupee    INR
#> 133        AWG                       Aruban Florin    AWG
#> 134        KRW                    South Korean Won    KRW
#> 135        NPR                      Nepalese Rupee    NPR
#> 136        JPY                        Japanese Yen    JPY
#> 137        MNT                    Mongolian Tugrik    MNT
#> 138        PLN                        Polish Zloty    PLN
#> 139        AOA                      Angolan Kwanza    AOA
#> 140        GBP              British Pound Sterling    GBP
#> 141        SBD              Solomon Islands Dollar    SBD
#> 142        BYN                    Belarusian Ruble    BYN
#> 143        HUF                    Hungarian Forint    HUF
#> 144        BIF                     Burundian Franc    BIF
#> 145        MWK              Malawian Malawi Kwacha    MWK
#> 146        MGA                     Malagasy Ariary    MGA
#> 147        XDR              Special Drawing Rights    XDR
#> 148        BZD                       Belize Dollar    BZD
#> 149        BAM Bosnia-Herzegovina Convertible Mark    BAM
#> 150        MOP                     Macanese Pataca    MOP
#> 151        EGP                      Egyptian Pound    EGP
#> 152        NAD                     Namibian Dollar    NAD
#> 153        SSP                South Sudanese Pound    SSP
#> 154        NIO                  Nicaraguan Córdoba    NIO
#> 155        PEN                        Peruvian Sol    PEN
#> 156        NZD                  New Zealand Dollar    NZD
#> 157        WST                         Samoan Tala    WST
#> 158        TMT                 Turkmenistani Manat    TMT
#> 159        CLF        Chilean Unit of Account (UF)    CLF
#> 160        BRL                      Brazilian Real    BRL
#>                         local_long_name
#> 1                         Fijian Dollar
#> 2                          Mexican Peso
#> 3                     Seychellois Rupee
#> 4                       Congolese Franc
#> 5                      Barbadian Dollar
#> 6                    Guatemalan Quetzal
#> 7                          Chilean Peso
#> 8                      Honduran Lempira
#> 9                      Ugandan Shilling
#> 10                   South African Rand
#> 11              Mexican Investment Unit
#> 12                       Tunisian Dinar
#> 13          São Tomé and Príncipe Dobra
#> 14                 Sierra Leonean Leone
#> 15                 Sierra Leonean Leone
#> 16                      Bahamian Dollar
#> 17                       Sudanese Pound
#> 18                          Iraqi Dinar
#> 19                           Cuban Peso
#> 20                       Gambian Dalasi
#> 21                    New Taiwan Dollar
#> 22                        Serbian Dinar
#> 23                       Dominican Peso
#> 24                       Comorian Franc
#> 25                    Malaysian Ringgit
#> 26               Falkland Islands Pound
#> 27                      CFA Franc BCEAO
#> 28                        Georgian Lari
#> 29                       Uruguayan Peso
#> 30                      Moroccan Dirham
#> 31                  Cape Verdean Escudo
#> 32                       Tongan Paʻanga
#> 33               Papua New Guinean Kina
#> 34                           Omani Rial
#> 35                     Azerbaijan Manat
#> 36                      Kenyan Shilling
#> 37                        Swedish Krona
#> 38                    Ukrainian Hryvnia
#> 39                   Bhutanese Ngultrum
#> 40                        Guinean Franc
#> 41                   Mozambican Metical
#> 42                       Eritrean Nakfa
#> 43                     Salvadoran Colón
#> 44                       Argentine Peso
#> 45                          Qatari Rial
#> 46                         Iranian Rial
#> 47                            CFP Franc
#> 48                            Thai Baht
#> 49                       Uzbekistan Som
#> 50                         Chinese Yuan
#> 51                  Mauritanian Ouguiya
#> 52                     Bangladeshi Taka
#> 53                         Libyan Dinar
#> 54                      Bermudan Dollar
#> 55                        Kuwaiti Dinar
#> 56                      Philippine Peso
#> 57                        Russian Ruble
#> 58                   Paraguayan Guarani
#> 59                      Icelandic Króna
#> 60                      Jamaican Dollar
#> 61                       Colombian Peso
#> 62                            US Dollar
#> 63                     Macedonian Denar
#> 64                       Algerian Dinar
#> 65                    Panamanian Balboa
#> 66                     Singapore Dollar
#> 67                       Ethiopian Birr
#> 68                       Kyrgystani Som
#> 69                         Vanuatu Vatu
#> 70                      Somali Shilling
#> 71                              Lao Kip
#> 72                        Brunei Dollar
#> 73                       CFA Franc BEAC
#> 74                      Liberian Dollar
#> 75                          Swiss Franc
#> 76                                 Kuna
#> 77                     Djiboutian Franc
#> 78                         Albanian Lek
#> 79          Venezuelan Bolívar Soberano
#> 80                                  ZMW
#> 81                   Tanzanian Shilling
#> 82                      Vietnamese Dong
#> 83                    Australian Dollar
#> 84                   Israeli New Sheqel
#> 85                     Guyanaese Dollar
#> 86                     North Korean Won
#> 87                        Ghanaian Cedi
#> 88                       Cambodian Riel
#> 89                   Bolivian Boliviano
#> 90                         Moldovan Leu
#> 91                    Indonesian Rupiah
#> 92                Cayman Islands Dollar
#> 93                        Armenian Dram
#> 94                         Turkish Lira
#> 95                   Saint Helena Pound
#> 96                       Botswanan Pula
#> 97                       Lebanese Pound
#> 98                   Tajikistani Somoni
#> 99                      Jordanian Dinar
#> 100                    Hong Kong Dollar
#> 101         United Arab Emirates Dirham
#> 102                       Rwandan Franc
#> 103                                Euro
#> 104                        Lesotho Loti
#> 105                        Danish Krone
#> 106                     Canadian Dollar
#> 107                       Bulgarian Lev
#> 108                         Myanma Kyat
#> 109                        Syrian Pound
#> 110                     Norwegian Krone
#> 111                     Mauritian Rupee
#> 112                     Gibraltar Pound
#> 113                        Romanian Leu
#> 114                    Sri Lankan Rupee
#> 115                      Nigerian Naira
#> 116                   Costa Rican Colón
#> 117               Czech Republic Koruna
#> 118                     Pakistani Rupee
#> 119               East Caribbean Dollar
#> 120                      Haitian Gourde
#> 121       Netherlands Antillean Guilder
#> 122                   Caribbean Guilder
#> 123                      Bahraini Dinar
#> 124                   Surinamese Dollar
#> 125                   Kazakhstani Tenge
#> 126                     Swazi Lilangeni
#> 127          Trinidad and Tobago Dollar
#> 128                         Saudi Riyal
#> 129                         Yemeni Rial
#> 130                   Maldivian Rufiyaa
#> 131                      Afghan Afghani
#> 132                        Indian Rupee
#> 133                       Aruban Florin
#> 134                    South Korean Won
#> 135                      Nepalese Rupee
#> 136                        Japanese Yen
#> 137                    Mongolian Tugrik
#> 138                        Polish Zloty
#> 139                      Angolan Kwanza
#> 140              British Pound Sterling
#> 141              Solomon Islands Dollar
#> 142                    Belarusian Ruble
#> 143                    Hungarian Forint
#> 144                     Burundian Franc
#> 145              Malawian Malawi Kwacha
#> 146                     Malagasy Ariary
#> 147              Special Drawing Rights
#> 148                       Belize Dollar
#> 149 Bosnia-Herzegovina Convertible Mark
#> 150                     Macanese Pataca
#> 151                      Egyptian Pound
#> 152                     Namibian Dollar
#> 153                South Sudanese Pound
#> 154                  Nicaraguan Córdoba
#> 155                        Peruvian Sol
#> 156                  New Zealand Dollar
#> 157                         Samoan Tala
#> 158                 Turkmenistani Manat
#> 159        Chilean Unit of Account (UF)
#> 160                      Brazilian Real
# }
```
