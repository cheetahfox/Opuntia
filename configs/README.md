# Opuntia Configurations

Here are the detailed configurations for each firmware for Opuntia. All configurations include the [base] configuration. In general the customization for hardware types revolve around setting the correct CPU architecture and packages built. For the more limited hardware platforms we either pick smaller packages (vi vs vim-full) or don't include support for some things.  

# Generic build configs

For most people you will want to use the x86-64 configuration. This image is generic and includes the full feature support. 


# ImageStream Configurations

ImageStream hardware model to build configuration. 

| Hardware | Configuration |
| -------- | ------------- |
| AP2000v2 | ap2000-hw2    |
| AP2000v3 | ap2000        |
| AP2100v3 | ap2100        |
| EV1000v4 | ev1000        |
