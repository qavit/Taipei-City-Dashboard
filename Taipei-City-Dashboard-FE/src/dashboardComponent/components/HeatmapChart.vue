<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { computed, ref, watch } from "vue";
import VueApexCharts from "vue3-apexcharts";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

const emits = defineEmits([
	"filterByParam",
	"filterByLayer",
	"clearByParamFilter",
	"clearByLayerFilter",
	"fly",
]);

const heatmapData = computed(() => {
	let output = {};
	let highest = 0;
	let sum = 0;
	if (props.series.length === 1) {
		props.series[0].data.forEach((item) => {
			output[item.x] = item.y;
			if (item.y > highest) {
				highest = item.y;
			}
			sum += item.y;
		});
	} else {
		props.series.forEach((serie) => {
			for (let i = 0; i < props.chart_config.categories.length; i++) {
				if (!output[props.chart_config.categories[i]]) {
					output[props.chart_config.categories[i]] = 0;
				}
				output[props.chart_config.categories[i]] += +serie.data[i];

				if (+serie.data[i] > highest) highest = +serie.data[i];
			}
		});
		sum = Object.values(output).reduce(
			(partialSum, a) => partialSum + a,
			0
		);
	}

	output.highest = highest;
	output.sum = sum;
	return output;
});

const colorScale = computed(() => {
	const ranges = props.chart_config.color.map((el, index) => ({
		to: Math.floor(
			(heatmapData.value.highest / props.chart_config.color.length) *
				(props.chart_config.color.length - index)
		),
		from:
			Math.floor(
				(heatmapData.value.highest / props.chart_config.color.length) *
					(props.chart_config.color.length - index - 1)
			) + 1,
		color: el,
	}));
	ranges.unshift({
		to: 0,
		from: 0,
		color: "#444444",
	});
	return ranges;
});

const isLargeDataSet = computed(() => {
	return props.series[0].data.length > 12;
});

// Calculate initial width for large datasets only
const initialWidth = computed(() => {
	const WIDTH_PER_ITEM = 30;
	const itemCount = props.series[0].data.length;
	return itemCount * WIDTH_PER_ITEM + 100;
});

const widthValue = ref(initialWidth.value);

// Convert to a string with unit for ApexCharts
const chartWidth = computed(() => {
	return isLargeDataSet.value ? `${widthValue.value}px` : "100%";
});

const cellSize = computed(() => {
	if (!isLargeDataSet.value) return 30;
	return Math.max(25, widthValue.value / props.series[0].data.length - 2);
});

const shouldShowDataLabels = computed(() => {
	return cellSize.value >= 30;
});

const chartOptions = ref({
	chart: {
		stacked: true,
		toolbar: isLargeDataSet.value
			? {
					show: true,
					tools: {
						download: false,
						pan: false,
						reset: "<p>重置</p>",
						zoomin: false,
						zoomout: false,
					},
			  }
			: {
					show: false,
			  },
		height: 250,
		redrawOnParentResize: true,
	},
	dataLabels: {
		enabled: shouldShowDataLabels.value,
		style: {
			fontSize: "12px",
		},
	},
	grid: {
		show: false,
		padding: {
			left: 5,
			right: 0,
		},
	},
	legend: {
		show: false,
	},
	plotOptions: {
		heatmap: {
			enableShades: false,
			radius: 2,
			colorScale: {
				ranges: colorScale.value,
			},
			distributed: true,
			useFillColorAsStroke: false,
			cellSize: cellSize.value,
			cellPadding: 0,
		},
	},
	stroke: {
		show: true,
		width: 2,
		colors: ["#282a2c"],
	},
	tooltip: {
		custom: function ({ series, seriesIndex, dataPointIndex, w }) {
			return (
				'<div class="chart-tooltip">' +
				"<h6>" +
				`${w.globals.labels[dataPointIndex]}-${w.globals.seriesNames[seriesIndex]}` +
				"</h6>" +
				"<span>" +
				`${series[seriesIndex][dataPointIndex]}${props.chart_config.unit}` +
				"</span>" +
				"</div>"
			);
		},
	},
	xaxis: {
		axisBorder: {
			show: false,
		},
		axisTicks: {
			show: false,
		},
		categories: props.chart_config.categories || [],
		labels: {
			offsetY: 2,
			formatter: function (value) {
				return value.length > 7 ? value.slice(0, 6) + "..." : value;
			},
		},
		tooltip: {
			enabled: false,
		},
	},
	yaxis: {
		max: function (max) {
			return props.chart_config.categories
				? heatmapData.value.highest
				: max;
		},
		labels: {
			align: "right",
			style: {
				fontSize: "11px",
			},
			padding: {
				right: 5,
			},
			trim: false,
		},
	},
});

// 監聽 widthValue 的變化來更新圖表配置
watch([widthValue, shouldShowDataLabels], ([newWidth, showLabels]) => {
	chartOptions.value = {
		...chartOptions.value,
		dataLabels: {
			...chartOptions.value.dataLabels,
			enabled: showLabels,
		},
		plotOptions: {
			...chartOptions.value.plotOptions,
			heatmap: {
				...chartOptions.value.plotOptions.heatmap,
				cellSize: cellSize.value,
			},
		},
	};
});

const selectedIndex = ref(null);

function handleDataSelection(_e, _chartContext, config) {
	if (!props.map_filter || !props.map_filter_on) {
		return;
	}
	if (
		`${config.dataPointIndex}-${config.seriesIndex}` !== selectedIndex.value
	) {
		// Supports filtering by xAxis + yAxis
		if (props.map_filter.mode === "byParam") {
			emits(
				"filterByParam",
				props.map_filter,
				props.map_config,
				config.w.globals.labels[config.dataPointIndex],
				config.w.globals.seriesNames[config.seriesIndex]
			);
		}
		// Supports filtering by xAxis
		else if (props.map_filter.mode === "byLayer") {
			emits(
				"filterByLayer",
				props.map_config,
				config.w.globals.labels[config.dataPointIndex]
			);
		}
		selectedIndex.value = `${config.dataPointIndex}-${config.seriesIndex}`;
	} else {
		if (props.map_filter.mode === "byParam") {
			emits("clearByParamFilter", props.map_config);
		} else if (props.map_filter.mode === "byLayer") {
			emits("clearByLayerFilter", props.map_config);
		}
		selectedIndex.value = null;
	}
}

function increaseWidth() {
	widthValue.value += 50;
}

function decreaseWidth() {
	if (widthValue.value > 150) {
		widthValue.value -= 50;
	}
}

function resetWidth() {
	widthValue.value = initialWidth.value;
}
</script>

<template>
	<div v-if="activeChart === 'HeatmapChart'" class="heatmapchart">
		<div class="heatmapchart-header">
			<div class="heatmapchart-title">
				<h5>總合</h5>
				<h6>
					{{ heatmapData.sum.toLocaleString() }}
					{{ chart_config.unit }}
				</h6>
			</div>
			<div v-if="isLargeDataSet" class="heatmapchart-toolbar">
				<p class="heatmapchart-toolbar-item" @click="increaseWidth">
					<span>add</span>
				</p>
				<p class="heatmapchart-toolbar-item" @click="decreaseWidth">
					<span>remove</span>
				</p>
				<p class="heatmapchart-toolbar-item reset" @click="resetWidth">
					重置
				</p>
			</div>
		</div>
		<div class="heatmapchart-wrapper">
			<div class="heatmapchart-container">
				<VueApexCharts
					:key="chartWidth"
					:width="chartWidth"
					height="250px"
					type="heatmap"
					:options="chartOptions"
					:series="series"
					@data-point-selection="handleDataSelection"
				/>
			</div>
		</div>
	</div>
</template>

<style scoped lang="scss">
.heatmapchart {
	&-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem 1rem 0;
		margin-bottom: -0.5rem;
	}

	&-title {
		display: flex;
		flex-direction: column;

		h5,
		h6 {
			margin: 0;
			color: var(--color-complement-text);
		}

		h6 {
			font-size: var(--font-m);
			font-weight: 400;
		}
	}

	&-toolbar {
		display: flex;
		align-items: center;
		gap: 4px;
		margin-left: 1rem;

		&-item {
			cursor: pointer;
			font-size: var(--font-s);
			display: flex;
			justify-content: center;
			align-items: center;
			margin: 0;

			span {
				text-align: center;
				font-family: var(--font-icon);
				font-size: var(--font-ms);
				padding: 2px;
			}

			&.reset {
				color: var(--color-highlight);
			}
		}
	}

	&-wrapper {
		width: 100%;
		overflow-x: auto;
		overflow-y: hidden;

		&::-webkit-scrollbar {
			height: 8px;
		}

		&::-webkit-scrollbar-track {
			background: #f1f1f1;
			border-radius: 4px;
		}

		&::-webkit-scrollbar-thumb {
			background: #888;
			border-radius: 4px;

			&:hover {
				background: #555;
			}
		}
	}

	&-container {
		min-width: fit-content;
	}
}
</style>
