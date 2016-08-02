angular.module("reportService", []);

(function () {
  "use strict";

  angular.module("reportService").factory("topReports", dataFactory);

  dataFactory.$inject = ['$http'];

  function dataFactory($http) {
    var funcs = {}

    // Returns the top URLs report
    // TODO: Untangle dependency on ngTable 'params'. getTopUrls does not necessarily
    //       need to be responsible for sorting and paging unless it's tied into the
    //       server-side.
    funcs.getTopUrls = function(params) {
      return $http.get('/top_urls.json').then(function(res) {
        var dates = Object.keys(res.data);
        var _data = []

        // TODO: Request data of length 'count' instead of using .slice()
        for(var i = 0; i < dates.length; i++) {
          for(var j = 0; j < res.data[dates[i]].length; j++ ) {
            _data.push( { date: dates[i], url: res.data[dates[i]][j].url, visits: res.data[dates[i]][j].visits } )
          }
        }

        params.total(_data.length);

        // Sort the set, if requested
        // Note: ngTables will only ever put 0 or 1 key/value pair in params.sorting()
        var sorting = Object.keys(params.sorting()).length > 0;
        if(sorting) {
          var sort_column = Object.keys(params.sorting())[0];
          var sort_direction = params.sorting()[sort_column];
          _data = _data.sort(function(left, right) {
            if(sort_direction == "desc") {
              return left[sort_column] < right[sort_column] ? 1 : -1
            } else {
              return left[sort_column] >= right[sort_column] ? 1 : -1
            }
          });
        }

        // Paginate the set (TODO: This should really be done server-side)
        var sliceBegin = (params.page() - 1) * params.count();
        var sliceEnd = params.page() * params.count()

        return _data.slice(sliceBegin, sliceEnd);
      });
    }

    // Returns the top referrers report
    // TODO: Untangle dependency on ngTable 'params'. getTopUrls does not necessarily
    //       need to be responsible for sorting and paging unless it's tied into the
    //       server-side.
    funcs.getTopReferrers = function(params) {
      return $http.get('/top_referrers.json').then(function(res) {
        var dates = Object.keys(res.data);
        var _data = []

        // TODO: Request data of length 'count' instead of using .slice()
        for(var i = 0; i < dates.length; i++) {
          for(var j = 0; j < res.data[dates[i]].length; j++ ) {
            for(var k = 0; k < res.data[dates[i]][j].referrers.length; k++) {
              _data.push( { date: dates[i], url: res.data[dates[i]][j].url, total_visits: res.data[dates[i]][j].visits, referrer: res.data[dates[i]][j].referrers[k].url, referrer_visits: res.data[dates[i]][j].referrers[k].visits } )
            }
          }
        }

        params.total(_data.length);

        // Sort the set, if requested
        // Note: ngTables will only ever put 0 or 1 key/value pair in params.sorting()
        var sorting = Object.keys(params.sorting()).length > 0;
        if(sorting) {
          var sort_column = Object.keys(params.sorting())[0];
          var sort_direction = params.sorting()[sort_column];
          _data = _data.sort(function(left, right) {
            if(sort_direction == "desc") {
              return left[sort_column] < right[sort_column] ? 1 : -1
            } else {
              return left[sort_column] >= right[sort_column] ? 1 : -1
            }
          });
        }

        // Paginate the set (TODO: This should really be done server-side)
        var sliceBegin = (params.page() - 1) * params.count();
        var sliceEnd = params.page() * params.count()

        return _data.slice(sliceBegin, sliceEnd);
      });
    }

    return funcs;
  }
})();

(function () {
  "use strict";

  var app = angular.module("applytics", ["ngTable", "reportService"]);

  app.controller("reportController", reportController);

  reportController.$inject = ["NgTableParams", "$http", "$scope", "topReports"];

  function reportController(NgTableParams, $http, $scope, topReports) {
    var self = this;
    $scope.currentReport = 'urls';

    // ngTables configuration
    this.topUrlsCols = [
      { field: "date", title: "Date", sortable: "date", show: true },
      { field: "url", title: "URL", sortable: "url", show: true },
      { field: "visits", title: "Visits", sortable: "visits", show: true }
    ];
    this.topReferrersCols = [
      { field: "date", title: "Date", sortable: "date", show: true },
      { field: "url", title: "URL", sortable: "url", show: true },
      { field: "total_visits", title: "Total Visits", sortable: "total_visits", show: true },
      { field: "referrer", title: "Referrer", sortable: "referrer", show: true },
      { field: "referrer_visits", title: "Referrer Visits", sortable: "referrer_visits", show: true }
    ];

    this.cols = this.topUrlsCols;

    // ngTables data fetching
    this.tableParams = new NgTableParams({}, {
      getData: function(params) {
        // TODO: Add support for paging, sorting, and cache the $http results.
        if($scope.currentReport == 'urls') {
          return topReports.getTopUrls(params);
        } else if ($scope.currentReport == 'referrers') {
          return topReports.getTopReferrers(params);
        }
      }
    });

    $scope.switchReport = function(name) {
      $scope.currentReport = name;
      
      // Adjust table columns accordingly
      if(name == 'urls') {
        self.cols = self.topUrlsCols;
      } else if(name == 'referrers') {
        self.cols = self.topReferrersCols;
      }

      self.tableParams.reload();
    }
  }
})();

(function () {
  "use strict";

  angular.module("applytics").run(configureDefaults);
  configureDefaults.$inject = ["ngTableDefaults"];

  function configureDefaults(ngTableDefaults) {
    ngTableDefaults.params.count = 50;
  }
})();
