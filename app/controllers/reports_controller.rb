class ReportsController < ApplicationController
    # SELECT (CURDATE() - INTERVAL 1 DAY) as date, url, count(*) as hits FROM applytics.logs where created_at >= (CURDATE() - INTERVAL 2 DAY) and (created_at < (CURDATE() - INTERVAL 1 DAY)) group by(url);
    def top_urls

    end

    #
    def top_referrers

    end
end
