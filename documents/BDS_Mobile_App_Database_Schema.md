# British Deer Society Mobile App — Database Schema

*Auto-generated from the local Supabase database's actual schema via [mermerd](https://github.com/KarnerTh/mermerd). Do not edit by hand — regenerate after any migration change by running `supabase/scripts/generate-schema-diagram.sh` (requires the local stack to be running: `supabase start`).*

```mermaid
erDiagram
    address {
        integer address_type_id FK "{NOT_NULL}"
        text county 
        timestamp_with_time_zone created_at "{NOT_NULL}"
        uuid created_by FK "{NOT_NULL}"
        timestamp_with_time_zone edited_at 
        uuid edited_by FK 
        uuid id PK "{NOT_NULL}"
        text line_1 "{NOT_NULL}"
        text line_2 
        text line_3 
        text line_4 
        uuid person_id FK "{NOT_NULL}"
        text postcode "{NOT_NULL}"
        text town "{NOT_NULL}"
    }

    address_type {
        integer id PK "{NOT_NULL}"
        text label "{NOT_NULL}"
    }

    member {
        timestamp_with_time_zone created_at "{NOT_NULL}"
        uuid created_by FK "{NOT_NULL}"
        timestamp_with_time_zone edited_at 
        uuid edited_by FK 
        uuid id PK,FK "{NOT_NULL}"
        date joined_at 
        text membership_number 
        integer region_id FK "{NOT_NULL}"
        member_role role "{NOT_NULL} <member,regional_coordinator,national_admin>"
    }

    membership_level {
        integer id PK "{NOT_NULL}"
        text label "{NOT_NULL}"
    }

    membership_period {
        timestamp_with_time_zone created_at "{NOT_NULL}"
        uuid created_by FK "{NOT_NULL}"
        timestamp_with_time_zone edited_at 
        uuid edited_by FK 
        date effective_from "{NOT_NULL}"
        date effective_to "{NOT_NULL}"
        uuid id PK "{NOT_NULL}"
        uuid member_id FK "{NOT_NULL}"
        integer membership_level_id FK "{NOT_NULL}"
    }

    person {
        timestamp_with_time_zone created_at "{NOT_NULL}"
        uuid created_by FK "{NOT_NULL} Standing convention for all member-authored tables: created_at/created_by required, edited_at/edited_by null until first edit (populated by the set_edited_metadata trigger)."
        date date_of_birth 
        timestamp_with_time_zone edited_at 
        uuid edited_by FK 
        text first_names "{NOT_NULL}"
        text last_name "{NOT_NULL}"
        text title 
        uuid user_id PK,FK "{NOT_NULL}"
    }

    region {
        integer id PK "{NOT_NULL}"
        text label "{NOT_NULL}"
    }

    address }o--|| address_type : "address_type_id"
    address }o--|| person : "person_id"
    member |o--|| person : "id"
    member }o--|| region : "region_id"
    membership_period }o--|| member : "member_id"
    membership_period }o--|| membership_level : "membership_level_id"
```
